API     = require './api'
Cookies = require 'cookies-js'

module.exports =

  fetchSubjectSetsBasedOnProps: ->

    # Establish a callback for after subjects are fetched - to apply additional state changes:
    postFetchCallback = (subject_sets) =>
      return if subject_sets.length == 0

      state = {}

      # retrieve any existing bookmark for current subject set
      key = @getActiveWorkflow().name + '_' + @getCurrentSubject().subject_set_id
      state.subject_index = parseInt( Cookies.get(key) - 1 ) || 0

      # If a specific subject id indicated..
      if @props.query.selected_subject_id?
        # Get the index of the specified subject in the (presumably first & only) subject set:
        state.subject_index = (ind for subj,ind in subject_sets[0].subjects when subj.id == @props.query.selected_subject_id )[0] ? 0

      # If a specific page is indicated
      else if @props.query.page?
        state.subject_index = parseInt( @props.query.page - 1 )

      # If taskKey specified, now's the time to set that too:
      state.taskKey = @props.query.mark_task_key if @props.query.mark_task_key

      @setState state if state

    # Fetch by subject-set id?
    subject_set_id = @props.params.subject_set_id ? @props.query.subject_set_id
    if subject_set_id?
      @fetchSubjectSet subject_set_id, postFetchCallback

    # Fetch subject-sets by filters:
    else
      # Gather filters by which to query subject-sets
      params =
        group_id:                 @props.query.group_id ? null
      @fetchSubjectSets params, postFetchCallback



  # this method fetches the next page of subjects in a given subject_set.
  # right now the trigger for this method is the forward or back button in the light-box
  # I am torn about whether to set the subject_index at this point? -- AMS
  # fetchNextSubjectPage: (page_number, callback_fn) ->

    # Gather filters by which to query subject-sets
    # params =
    #  subject_set_id: subject_set_id
    #  workflow_id: workflow_id
    #  subject_page: page_number

    # @fetchSubjectSets params, () =>
    #  @setState subject_index: subject_index
    # callback_fn()

  orderSubjectsByOrder: (subject_sets) ->
    for subject_set in subject_sets
      subject_set.subjects = subject_set.subjects.sort (a,b) ->
        return if a.order >= b.order then 1 else -1
    subject_sets

  # Fetch a single subject-set (i.e. via SubjectSetsController#show)
  # Query hash added to prevent local mark from being re-transcribable.
  fetchSubjectSet: (subject_set_id, callback) ->
    request = API.type("subject_sets").get subject_set_id, {}

    request.then (set) =>
      @setState subjectSets: [set], () =>
        @fetchSubjectsForCurrentSubjectSet 1, null, callback

  # This is the main fetch method for subject sets. (fetches via SubjectSetsController#index)
  fetchSubjectSets: (params, callback) ->
    params = $.extend(workflow_id: @getActiveWorkflow().id, params)
    _callback = (sets) =>

    # Apply defaults to unset params:
    _params = $.extend({
      limit: 10
      workflow_id: @getActiveWorkflow().id
      random: true
    }, params)
    # Strip null params:
    params = {}; params[k] = v for k,v of _params when v?

    API.type('subject_sets').get(params).then (sets) =>

      @setState subjectSets: sets, () =>
        @fetchSubjectsForCurrentSubjectSet 1, null, callback

  # PB: Setting default limit to 120 because it's a multiple of 3 mandated by thumb browser
  fetchSubjectsForCurrentSubjectSet: (page=1, limit=120, callback) ->
    ind = @state.subject_set_index
    sets = @state.subjectSets


    # page & limit not passed when called this way for some reason, so we have to manually construct query:
    # sets[ind].get('subjects', {page: page, limit: limit}).then (subjs) =>
    params =
      subject_set_id: sets[ind].id
      page: page
      limit: limit
      type: 'root'
      status: 'any'

    process_subjects = (subjs) =>
      sets[ind].subjects = subjs

      @setState
        subjectSets:                sets
        subjects_current_page:      subjs[0].getMeta('current_page')
        subjects_total_pages:       subjs[0].getMeta('total_pages'), () =>
          callback? sets


    # Couldn't get this code to work with the changes. Commenting for now. --STI
    # # Since we're fetching by query, json-api-client won't cache it, so let's cache it lest we re-fetch subjects everytime something happens:
    # @_subject_queries ||= {}
    # console.log '@_subject_queries[params] = ', @_subject_queries[params]
    # if (subjects = @_subject_queries[params])?
    #   process_subjects subjects
    #
    # else

    @_subject_queries ||= {}
    API.type('subjects').get(params).then (subjects) =>
      @_subject_queries[params] = subjects
      process_subjects subjects

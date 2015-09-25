API = require './api'

module.exports =

  fetchSubjectSetsBasedOnProps: ->

    # Establish a callback for after subjects are fetched - to apply additional state changes:
    postFetchCallback = (subject_sets) =>
      return if subject_sets.length == 0

      state = {}

      # If a specific subject id indicated..
      if @props.query.selected_subject_id?
        # Get the index of the specified subject in the (presumably first & only) subject set:
        state.subject_index = (ind for subj,ind in subject_sets[0].subjects when subj.id == @props.query.selected_subject_id )[0]

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
  fetchNextSubjectPage: (subject_set_id, workflow_id, page_number, subject_index, callback_fn) ->

    # Gather filters by which to query subject-sets
    params =
      subject_set_id: subject_set_id
      workflow_id: workflow_id
      subject_page: page_number

    @fetchSubjectSets params, () =>
      @setState subject_index: subject_index
      callback_fn()

  orderSubjectsByOrder: (subject_sets) ->
    for subject_set in subject_sets
      subject_set.subjects = subject_set.subjects.sort (a,b) ->
        return if a.order >= b.order then 1 else -1
    subject_sets

  # Fetch a single subject-set (i.e. via SubjectSetsController#show)
  fetchSubjectSet: (subject_set_id, callback) ->
    request = API.type("subject_sets").get subject_set_id

    request.then (subject_set) =>
      @_handleFetchedSubjectSets [subject_set], callback

  # This is the main fetch method for subject sets. (fetches via SubjectSetsController#index)
  fetchSubjectSets: (params, callback) ->
    # Apply defaults to unset params:
    _params = $.extend({
      limit: 1 #10 # temporary fix for large subject_sets -STI
      workflow_id: @getActiveWorkflow().id
      random: true
    }, params)
    # Strip null params:
    params = {}; params[k] = v for k,v of _params when v?

    API.type('subject_sets').get(params).then (subject_sets) =>
      @_handleFetchedSubjectSets subject_sets, callback


  # Used internally by mixin to update state and fire callbacks after retrieving sets
  _handleFetchedSubjectSets: (subject_sets, callback) ->

    # Establish a no-results state:
    state = subjectSets: []

    if subject_sets.length > 0
      state =
        subjectSets: @orderSubjectsByOrder(subject_sets)
        subject_set_index: 0
        subject_sets_current_page: subject_sets[0].getMeta("current_page")
        subject_sets_total_pages: subject_sets[0].getMeta("total_pages")
        subjects_current_page: subject_sets[0].subjects_pagination_info.current_page
        subjects_total_pages: subject_sets[0].subjects_pagination_info.total_pages

    @setState state

    callback? subject_sets

    if @fetchSubjectsCallback?
      @fetchSubjectsCallback()

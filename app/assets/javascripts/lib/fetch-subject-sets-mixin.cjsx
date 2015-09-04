API = require './api'

# TODO PB: There are like sixteen different ways to do the same thing in here; Should simplify

module.exports =
  componentDidMount: ->

    # Gather filters by which to query subject-sets
    params =
      subject_set_id:           @props.params.subject_set_id ? @props.query.subject_set_id
      group_id:                 @props.query.group_id ? null

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

    @fetchSubjectSets params, postFetchCallback

    """
    if @props.params.subject_set_id
        # console.log '>>>>>>>>>>>>>>>>>>>>>>>>>>>> A <<<<<<<<<<<<<<<<<<<<<<<<<<<<'
        # Used for directly accessing a subject set
        @fetchSubjectSet @props.params.subject_set_id, @getActiveWorkflow().id # fetch specific subject set
    else if @props.query.subject_set_id

      if @props.query.selected_subject_id and @props.query.selected_subject_id
        # console.log '>>>>>>>>>>>>>>>>>>>>>>>>>>>> B <<<<<<<<<<<<<<<<<<<<<<<<<<<<'
        # Used to transition from Transcribe to Mark
        @fetchSubjectSetBySubjectId @getActiveWorkflow().id, @props.query.subject_set_id, @props.query.selected_subject_id, @props.query.mark_task_key #, @props.query.page ? 1 # Forget why I decided to pass page number? --STI
      else
        # console.log '>>>>>>>>>>>>>>>>>>>>>>>>>>>> C <<<<<<<<<<<<<<<<<<<<<<<<<<<<'
        @fetchSubjectSet @props.query.subject_set_id, @getActiveWorkflow().id # fetch specific subject set
    else
      # console.log 'Fetching some subject set...'
      # console.log '>>>>>>>>>>>>>>>>>>>>>>>>>>>> D <<<<<<<<<<<<<<<<<<<<<<<<<<<<'
      @fetchSubjectSets @getActiveWorkflow().id, @getActiveWorkflow().subject_fetch_limit # fetch random subject sets, given limit
    """

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

    """
    request = API.type("subject_sets").get("#{subject_set_id}", page: page_number, workflow_id: workflow_id)

    @setState
      subjectSet: []

    request.then (subject_set) =>
      # console.log 'fetchNextSubjectPage() callback!'
      callback_fn()? # fixes weird pagination bugs; not too happy about this one --STI
      @setState
        subjectSets: subject_set
        subject_set_index: 0
        subject_index: subject_index || 0 # not sure that subject_index should be set here.
        subject_current_page: subject_set.subject_pagination_info.current_page
        total_subject_pages: subject_set.subject_pagination_info.total_pages
    """

  # PB: Deprecated; previously only called inside this mixin
  __DEP_fetchSubjectSetBySubjectId: (workflow_id, subject_set_id, selected_subject_id, mark_task_key) ->
    @fetchSubjectSets
  # fetchSubjectSetBySubjectId: (workflow_id, subject_set_id, selected_subject_id, page) -> # why page number? --STI
    # console.log 'fetchSubjectSetBySubjectId()'
    # console.log 'THE QUERY: ', "/workflows/#{workflow_id}/subject_sets/#{subject_set_id}/subjects/#{selected_subject_id}"
    request = API.type('workflows').get("#{workflow_id}/subject_sets/#{subject_set_id}/subjects/#{selected_subject_id}") #?page=#{page}")
    # request = API.type("subject_sets").get(subject_set_id: subject_set_id, workflow_id: workflow_id)

    @setState
      subjectSet: []
      # currentSubjectSet: null

    request.then (subject_set) =>
      for subject in subject_set.subjects
        if subject.id is subject_set.selected_subject_id
          subject_index = subject_set.subjects.indexOf subject

      @setState
        subjectSets: [subject_set]
        subject_set_index: 0
        subject_index: subject_index || 0 #parseInt(subject_index) || 0
        subject_current_page: subject_set.subjects_pagination_info.current_page
        total_subject_pages: subject_set.subjects_pagination_info.total_pages
        currentSubjectSet: subject_set
        taskKey: mark_task_key

  orderSubjectsByOrder: (subject_sets) ->
    for subject_set in subject_sets
      subject_set.subjects = subject_set.subjects.sort (a,b) ->
        return if a.order >= b.order then 1 else -1
    subject_sets

  # PB: Deprecated; previously only called inside this mixin
  __DEP_fetschSubjectSet: (subject_set_id, workflow_id)->
    @
    # console.log 'fetchSubjectSet()'
    request = API.type("subject_sets").get(subject_set_id: subject_set_id, workflow_id: workflow_id)

    @setState
      subjectSet: []
      # currentSubjectSet: null

    request.then (subject_set) =>
      @setState
        subjectSet: subject_set
        subjectSets: subject_set
        subject_set_index: 0
        subject_index: 0 #parseInt(subject_index) || 0
          # , => console.log 'STATE: ', @state


  # This is the main fetch method for subject sets.
  fetchSubjectSets: (params, callback) ->
    # Apply defaults to unset params:
    _params = $.extend({
      limit: 10
      workflow_id: @getActiveWorkflow().id
      random: true
    }, params)
    # Strip null params:
    params = {}; params[k] = v for k,v of _params when v?

    API.type('subject_sets').get(params).then (subject_sets) =>

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

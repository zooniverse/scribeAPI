API = require './api'

module.exports =
  componentDidMount: ->

    # Fetching a single subject?
    if @props.params.subject_id?
      @fetchSubject @props.params.subject_id

    # Fetching subjects by current workflow and optional filters:
    else
      # Gather filters by which to query subjects
      params =
        parent_subject_id:        @props.params.parent_subject_id
        group_id:                 @props.query.group_id ? null
        subject_set_id:           @props.query.subject_set_id ? null
      @fetchSubjects params

    """
    # SO. MANY. BRANCHES. --STI
    if @getActiveWorkflow().name is 'transcribe'
      # console.log 'Figuring out how to fetch transcribe subjects...'

      # fetch specific transcribe subject (only one!)
      if @props.params.subject_id?
        # console.log 'Fetching specific transcribe subject (only one!)...'
        @fetchSubject @props.params.subject_id, @getActiveWorkflow().id

      # fetch all subjects on current page
      else if @props.params.workflow_id? and @props.params.parent_subject_id?
        # console.log 'Fetching all transcribe subjects on this page...'
        @fetchSubjectsOnPage @props.params.workflow_id, @props.params.parent_subject_id

      else  # just fetch subjects randomly
        @fetchSubjects @getActiveWorkflow().id, @getActiveWorkflow().subject_fetch_limit

    else if @getActiveWorkflow().name is "mark"
        @fetchSubjectSets @getActiveWorkflow().id, @getActiveWorkflow().subject_fetch_limit
    else
      @fetchSubjects @getActiveWorkflow().id, @getActiveWorkflow().subject_fetch_limit
    """

  orderSubjectsByY: (subjects) ->
    subjects.sort (a,b) ->
      return if a.region.y >= b.region.y then 1 else -1

  # Fetch a single subject:
  fetchSubject: (subject_id)->
    request = API.type("subjects").get subject_id

    @setState
      subject: []

    request.then (subject) =>
      @setState
        subject_index: 0
        subjects: [subject],
        () =>
          if @fetchSubjectsCallback?
            @fetchSubjectsCallback()


  # used by the "Transcribe this page now!" button
  # __DEP_fetchSubjectsOnPage: (workflow_id, parent_subject_id) ->
  #  # console.log 'fetchSubjectsOnPage()'
  #  request = API.type('subjects.json').get
  #    workflow_id: workflow_id
  #    parent_subject_id: parent_subject_id

  #  # console.log "Fetching subjects on page: "
  #   request.then (subjects) =>
  #     # console.log 'SUBJECTS: ', subjects
  #     subjects = @orderSubjectsByY(subjects)
  #     if subjects.length is 0
  #       @setState noMoreSubjects: true, => console.log 'SET NO MORE SUBJECTS FLAG TO TRUE'
  #     else
  #       @setState
  #         subject_index: 0
  #         subjects: subjects
  #         subjects_next_page: subjects[0].getMeta("next_page")
  # 
  #     # Does including instance have a defined callback to call when new subjects received?
  #     if @fetchSubjectsCallback?
  #       @fetchSubjectsCallback()

  fetchSubjects: (params, callback) ->
    # Apply defaults to unset params:
    _params = $.extend({
      workflow_id: @getActiveWorkflow().id
      random: true
      page: 1
      limit: @getActiveWorkflow().subject_fetch_limit
    }, params)
    # Strip null params:
    params = {}; params[k] = v for k,v of _params when v?

    request = API.type('subjects').get(params).then (subjects) =>
      if subjects.length is 0
        @setState noMoreSubjects: true, => console.log 'SET NO MORE SUBJECTS FLAG TO TRUE'

      else
        @setState
          subject_index: 0
          subjects: subjects
          subjects: @orderSubjectsByY(subjects)
          subjects_next_page: subjects[0].getMeta("next_page")

      # Does including instance have a defined callback to call when new subjects received?
      if @fetchSubjectsCallback?
        @fetchSubjectsCallback()

API = require './api'

module.exports =
  componentDidMount: ->

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

  orderSubjectsByY: (subjects) ->
    subjects.sort (a,b) ->
      return if a.region.y >= b.region.y then 1 else -1

  fetchSubject: (subject_id, workflow_id)->
    request = API.type("subjects").get(subject_id, workflow_id: workflow_id)

    @setState
      subject: []
      currentSubject: null

    request.then (subject)=>
      @setState
        subjects: [subject]
        currentSubject: subject,
        () =>
          if @fetchSubjectsCallback?
            @fetchSubjectsCallback()


  # used by the "Transcribe this page now!" button
  fetchSubjectsOnPage: (workflow_id, parent_subject_id) ->
    # console.log 'fetchSubjectsOnPage()'
    request = API.type('subjects.json').get
      workflow_id: workflow_id
      parent_subject_id: parent_subject_id

    # console.log "Fetching subjects on page: "
    request.then (subjects) =>
      # console.log 'SUBJECTS: ', subjects
      subjects = @orderSubjectsByY(subjects)
      if subjects.length is 0
        @setState noMoreSubjects: true, => console.log 'SET NO MORE SUBJECTS FLAG TO TRUE'
      else
        @setState
          subject_index: 0
          subjects: subjects
          subjects_next_page: subjects[0].getMeta("next_page")

      # Does including instance have a defined callback to call when new subjects received?
      if @fetchSubjectsCallback?
        @fetchSubjectsCallback()

  fetchSubjects: (workflow_id, limit, page=1) ->
    if @props.overrideFetchSubjectsUrl?
      # console.log "Fetching (fake) subject sets from #{@props.overrideFetchSubjectsUrl}"
      $.getJSON @props.overrideFetchSubjectsUrl, (subjects) =>
        @setState
          subjects: subjects
          currentSubject: subjects[0]
        # Does including instance have a defined callback to call when new subjects received?
        if @fetchSubjectsCallback?
          @fetchSubjectsCallback()

    else
      request = API.type('subjects').get
        workflow_id: workflow_id
        limit: limit
        page: page
        scope: "active"
        random: true

      # console.log "Fetching subjects: "
      request.then (subjects) =>
        subjects = @orderSubjectsByY(subjects)
        if subjects.length is 0

          @setState noMoreSubjects: true, => console.log 'SET NO MORE SUBJECTS FLAG TO TRUE'
        else
          @setState
            subject_index: 0
            subjects: subjects
            subjects_next_page: subjects[0].getMeta("next_page")

        # Does including instance have a defined callback to call when new subjects received?
        if @fetchSubjectsCallback?
          @fetchSubjectsCallback()

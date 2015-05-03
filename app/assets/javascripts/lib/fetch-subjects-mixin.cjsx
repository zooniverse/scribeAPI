API            = require './api'

module.exports =
  componentDidMount: ->
    # console.log "Fetch Subjects Mixin: ", @

  #   # if @props.params.subject_set_id
  #   #   @fetchSubject @props.params.subject_set_id,@props.workflow.id
  #   # else
  #   #   @fetchSubjects @props.workflow.id, @props.workflow.subject_fetch_limit
  #
  #   if @props.workflow.name is "mark"
  #     @fetchSubjectSets @props.workflow.id, @props.workflow.subject_fetch_limit
  #   else
  #     @fetchSubjects @props.workflow.id, @props.workflow.subject_fetch_limit
  #
  # # NO LONGER BEING USED? -STI
  # # fetchSubject: (subject_set_id, workflow_id)->
  # #   console.log "SUBJECT FETCH"
  # #   request = API.type("subject_sets").get(subject_set_id, workflow_id: workflow_id)
  # #
  # #   @setState
  # #     subjectSet: []
  # #     currentSubjectSet: null
  # #
  # #   request.then (subject_set)=>
  # #     console.log("retrived subejct set", subject_set)
  # #     @setState
  # #       subjectSets: [subject_set]
  # #       currentSubjectSet: subject_set
  #
  # fetchSubjects: (workflow_id, limit) ->
  #   console.log 'FETCHING SUBJECTS'
  #   request = API.type("subjects").get
  #     workflow_id: workflow_id
  #     limit: limit
  #     random: true
  #
  #   request.then (subjects) =>
  #     if subjects.length is 0
  #       @setState noMoreSubjects: true
  #     else
  #       @setState
  #         subjects: subjects
  #         currentSubject: subjects[0], => console.log 'STATE: ', @state
  #
  # fetchSubjectSets: (workflow_id, limit) ->
  #   request = API.type('subject_sets').get
  #     workflow_id: workflow_id
  #     limit: limit
  #     random: true
  #
  #   request.then (subject_sets) =>
  #     if subject_sets.length is 0
  #       @setState noMoreSubjectSets: true
  #     else
  #       @setState
  #         subjectSets: subject_sets
  # #         currentSubjectSet: subject_sets[0]
  #   if @props.params.subject_id
  #     @fetchSubject @props.params.subject_id,@props.workflow.id
  #   else
  #     @fetchSubjects @props.workflow.id, @props.workflow.subject_fetch_limit
  #

    if @props.workflow.name is "mark"
      @fetchSubjectSets @props.workflow.id, @props.workflow.subject_fetch_limit
    else
      @fetchSubjects @props.workflow.id, @props.workflow.subject_fetch_limit

  fetchSubject: (subject_id, workflow_id)->
    console.log 'fetchSubject()'
    request = API.type("subjects").get(subject_id, workflow_id: workflow_id)

    @setState
      subject: []
      currentSubject: null

    request.then (subject)=>
      console.log("retrived subejct set", subject_set)
      @setState
        subject: [subject]
        currentSubject: subject

  fetchSubjects: (workflow_id, limit) ->
    console.log 'fetchSubjects()'

    if @props.overrideFetchSubjectsUrl?
      console.log "Fetching (fake) subject sets from #{@props.overrideFetchSubjectsUrl}"
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
        random: true

      request.then (subjects) =>
        console.log 'SUBJECTS: ', subjects
        if subjects.length is 0
          @setState noMoreSubjects: true, => console.log 'SET NO MORE SUBJECTS FLAG TO TRUE'
        else
          @setState
            subjects: subjects
            currentSubject: subjects[0], => console.log 'STATE: ', @state

        # Does including instance have a defined callback to call when new subjects received?
        if @fetchSubjectsCallback?
          @fetchSubjectsCallback()

API            = require './api'

module.exports =
  componentDidMount: ->
    if @activeWorkflow().name is 'transcribe' and @props.params.subject_id
      @fetchSubject @props.params.subject_id,@activeWorkflow().id
    # else if @activeWorkflow().name is "mark"
        # @fetchSubjectSets @activeWorkflow().id, @activeWorkflow().subject_fetch_limit
    else
      @fetchSubjects @activeWorkflow().id, @activeWorkflow().subject_fetch_limit

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

  fetchSubjects: (workflow_id, limit, page=1) ->
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
        page: page
        scope: "active"
        # random: true

      console.log "Fetching subjects: "
      request.then (subjects) =>
        subject = @orderSubjectsByY(subjects)
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


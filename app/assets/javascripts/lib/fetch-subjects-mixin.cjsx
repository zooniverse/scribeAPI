API            = require './api'

module.exports =
  componentDidMount: ->
    # console.log "Fetch Subjects Mixin: ", @

    if @props.params.subject_id
      @fetchSubject @props.params.subject_id,@props.workflow.id
    else
      @fetchSubjects @props.workflow.id, @props.workflow.subject_fetch_limit

  fetchSubject: (subject_id, workflow_id)->
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

      request.then (subjects)=>    # DEBUG CODE
        @setState
          subject: subjects
          currentSubject: subjects[0]


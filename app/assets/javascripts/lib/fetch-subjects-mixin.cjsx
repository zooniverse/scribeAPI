Classification = require 'models/classification'

module.exports =

  FetchSubjectsMixin = 

    componentDidMount: ->
      @fetchSubjects @props.workflow.id, @props.workflow.subject_fetch_limit

    fetchSubjects: (workflow_id, limit) ->
      console.log "ENDPOINT: /workflows/#{workflow_id}/subjects.json?limit=#{limit}"
      $.ajax
        url: "/workflows/#{workflow_id}/subjects.json?limit=#{limit}"
        dataType: "json"
        success: ((subjects) =>
          # DEBUG CODE
          console.log 'FETCHED SUBJECTS: ', subjects
          @setState 
            subjects: subjects
            currentSubject: subjects[0]
            classification: new Classification subjects[0]
        ).bind(this)
        error: ((xhr, status, err) ->
          console.error "Error loading subjects: ", url, status, err.toString()
        ).bind(this)
Classification = require 'models/classification'

module.exports =

  FetchSubjectsMixin = 

    componentDidMount: ->
      @fetchSubjects @props.workflow.id, @props.workflow.subject_fetch_limit

    fetchSubjects: (workflow_id, limit) ->
      $.ajax
        url: "/workflows/#{workflow_id}/subject_sets.json?limit=#{limit}"
        dataType: "json"
        success: ((subject_sets) =>
          # DEBUG CODE
          console.log 'FETCHED SUBJECTS: ', subject_sets
          @setState 
            subject_sets: subject_sets
            currentSubjectSet: subject_sets[0]
            # classification: new Classification subjects[0]
        ).bind(this)
        error: ((xhr, status, err) ->
          console.error "Error loading subjects: ", url, status, err.toString()
        ).bind(this)

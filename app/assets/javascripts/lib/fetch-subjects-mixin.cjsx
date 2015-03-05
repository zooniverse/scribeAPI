
module.exports =
  
  FetchSubjectsMixin = 

    componentDidMount: ->
      return unless @isMounted
      @fetchSubjects @props.workflow.id, 

    fetchSubjects: (workflow_id, limit) ->
      $.ajax
        url: "/workflows/#{workflow_id}/subjects.json?limit=#{limit}"
        dataType: "json"
        success: ((subjects) ->
          # DEBUG CODE
          console.log 'FETCHED SUBJECTS: ', subjects
          @setState subjects: subjects
        ).bind(this)
        error: ((xhr, status, err) ->
          console.error "Error loading subjects: ", url, status, err.toString()
        ).bind(this)
module.exports =
  
  FetchSubjectsMixin = 

    getJSON: (url) ->
      $.ajax
        url: url
        dataType: "json"
        success: ((data) ->
          # DEBUG CODE
          # console.log 'FETCHED SUBJECTS: ', data
          @setState
            subjects:       data
            currentSubject: data[0]
            # classification: new Classification subjects[0]
        ).bind(this)
        error: ((xhr, status, err) ->
          console.error "Error loading subjects: ", url, status, err.toString()
        ).bind(this)

    componentDidMount: ->
      return unless @isMounted
      @getJSON "/workflows/#{@props.workflow.id}/subjects.json?limit=5"
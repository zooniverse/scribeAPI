module.exports =
  
  FetchSubjectsMixin = 

    getJSON: (url, callback) ->
      $.ajax
        url: url
        dataType: "json"
        success: ((data) ->
          # DEBUG CODE
          # console.log 'FETCHED SUBJECTS: ', data
          callback(data)
        ).bind(this)
        error: ((xhr, status, err) ->
          console.error "Error loading subjects: ", url, status, err.toString()
        ).bind(this)

    loadSubjects: (subjects) ->
      @setState
        subjects: subjects
        currentSubject: subjects[0]

    componentDidMount: ->
      return unless @isMounted
      @getJSON "/workflows/#{@props.workflow.id}/subjects.json?limit=5", @loadSubjects
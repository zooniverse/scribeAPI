  fetchSubjects: ->
    $.ajax
      url: @state.subjectEndpoint
      dataType: "json"
      success: ((data) ->
        # DEBUG CODE
        console.log 'FETCHED SUBJECTS: ', data
        @setState
          subjects: data
          subject: data[0], =>
            @state.classification = new Classification @state.subject
            @loadImage @state.subject.location.standard

        # console.log 'Fetched Images.' # DEBUG CODE

        return
      ).bind(this)
      error: ((xhr, status, err) ->
        console.error "Error loading subjects: ", @state.subjectEndpoint, status, err.toString()
        return
      ).bind(this)
    return
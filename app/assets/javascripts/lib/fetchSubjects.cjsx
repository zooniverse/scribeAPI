module.exports = 
  fetchSubjects: (endpoint) ->
    console.log 'fetchSubjects()'
    $.ajax
      url: endpoint
      dataType: "json"
      success: ((subjects) ->
        # DEBUG CODE
        console.log 'FETCHED SUBJECTS: ', subjects
        return subjects
      ).bind(this)
      error: ((xhr, status, err) ->
        console.error "Error loading subjects: ", endpoint, status, err.toString()
        return
      ).bind(this)


  
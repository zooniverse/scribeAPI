Classification = require 'models/classification'
API            = require './api'

module.exports =
  componentDidMount: ->
    @fetchSubjects @props.workflow.id, @props.workflow.subject_fetch_limit

  fetchSubjects: (workflow_id, limit) ->
    request = API.type('subjects').get
      workflow_id: workflow_id
      limit: limit

    request.then (subjects)=>    # DEBUG CODE
      console.log 'FETCHED SUBJECTS: ', subjects
      @setState
        subjects: subjects
        currentSubject: subjects[0]

    request.error (xhr, status, err) =>
      console.error "Error loading subjects: ", url, status, err.toString()

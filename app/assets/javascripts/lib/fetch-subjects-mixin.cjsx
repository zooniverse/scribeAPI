API            = require './api'

module.exports =
  componentDidMount: ->

    # if @props.params.subject_set_id
    #   @fetchSubject @props.params.subject_set_id,@props.workflow.id
    # else
    #   @fetchSubjects @props.workflow.id, @props.workflow.subject_fetch_limit

    if @props.workflow.name is "mark"
      @fetchSubjectSets @props.workflow.id, @props.workflow.subject_fetch_limit
    else
      @fetchSubjects @props.workflow.id, @props.workflow.subject_fetch_limit

  fetchSubjects: (workflow_id, limit) ->
    console.log 'FETCHING SUBJECTS'
    request = API.type("subjects").get
      workflow_id: workflow_id
      limit: limit
      random: true

    request.then (subjects) =>
      if subjects.length is 0
        @setState noMoreSubjects: true
      else
        @setState
          subjects: subjects
          currentSubject: subjects[0], => console.log 'STATE: ', @state

  fetchSubjectSets: (workflow_id, limit) ->
    request = API.type('subject_sets').get
      workflow_id: workflow_id
      limit: limit
      random: true

    request.then (subject_sets) =>
      if subject_sets.length is 0
        @setState noMoreSubjectSets: true
      else
        @setState
          subjectSets: subject_sets
          currentSubjectSet: subject_sets[0]

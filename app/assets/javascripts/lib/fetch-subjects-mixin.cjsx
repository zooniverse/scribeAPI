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
      @fetchSubjects @props.params.subject_set_id,@props.workflow.id

  fetchSubjects: (workflow_id, limit)->
    request = API.type("subjects").get()
      workflow_id: workflow_id
      limit: limit
      random: true

    request.then (subjects)=>
      @setState
        subjects: subjects
        currentSubject: subjects[0]

  fetchSubjectSets: (workflow_id, limit) ->
    console.log 'FETCHING SUBJECT SETS'
    request = API.type('subject_sets').get
      workflow_id: workflow_id
      limit: limit
      random: true

    request.then (subject_sets)=>    # DEBUG CODE
      @setState
        subjectSets: subject_sets
        currentSubjectSet: subject_sets[0]

    # WHY DOES THIS BREAK?
    # request.error (xhr, status, err) =>
    #   console.error "Error loading subjects: ", url, status, err.toString()

API            = require './api'

module.exports =
  componentDidMount: ->
    # console.log "Fetch Subjects Mixin: ", @
    if @props.params.subject_set_id
      @fetchSubjectSet @props.params.subject_set_id,@props.workflow.id
    else
      @fetchSubjectSets @props.workflow.id, @props.workflow.subject_fetch_limit

  fetchSubjectSet: (subject_set_id, workflow_id)->
    request = API.type("subject_sets").get(subject_set_id, workflow_id: workflow_id)

    @setState
      subjectSet: []
      currentSubjectSet: null

    request.then (subject_set)=>
      @setState
        subjectSets: [subject_set]
        currentSubjectSet: subject_set

  fetchSubjectSets: (workflow_id, limit) ->

    if @props.overrideFetchSubjectsUrl?
      # console.log "Fetching (fake) subject sets from #{@props.overrideFetchSubjectsUrl}"
      $.getJSON @props.overrideFetchSubjectsUrl, (subject_sets) =>
        @setState
          subjectSets: subject_sets
          currentSubjectSet: subject_sets[0]

    else
      request = API.type('subject_sets').get
        workflow_id: workflow_id
        limit: limit
        random: true

      request.then (subject_sets)=>    # DEBUG CODE
        # console.log "subject sets",  subject_sets
        @setState
          subjectSets: subject_sets
          currentSubjectSet: subject_sets[0]
          currentSubject: subject_sets[0].subjects[0]

  # Once we get down to subject level, the subjects need to be sorted by region.y. 
  # 
  # orderChildSubjectsByY: ->
  #   for subject_set, i in subject_sets
  #     for subject, i in subject_set
  #       for key, value of subject




    # WHY DOES THIS BREAK?
    # request.error (xhr, status, err) =>
    #   console.error "Error loading subjects: ", url, status, err.toString()

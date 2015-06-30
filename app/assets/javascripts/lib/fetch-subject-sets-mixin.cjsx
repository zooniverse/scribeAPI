API = require './api'

module.exports =
  componentDidMount: ->
    # console.log "Fetch Subjects Mixin: ", @
    if @props.query.subject_set_id and !@props.query.selected_subject_id
      @fetchSubjectSet @props.query.subject_set_id, @props.query.subject_index, @props.workflow.id
    else if @props.query.subject_set_id and @props.query.selected_subject_id
      @fetchSubjectSetBySubjectId @props.workflow.id, @props.query.subject_set_id, @props.query.selected_subject_id
    else
      @fetchSubjectSets @props.workflow.id, @props.workflow.subject_fetch_limit

  fetchSubjectSet: (subject_set_id, subject_index, workflow_id)->
    console.log 'fetchSubjectSet()'
    request = API.type("subject_sets").get(subject_set_id: subject_set_id, workflow_id: workflow_id)

    @setState
      subjectSet: []
      # currentSubjectSet: null

    request.then (subject_set) =>
      @setState
        subjectSets: subject_set
        subject_set_index: 0
        subject_index: parseInt(subject_index) || 0
        # currentSubjectSet: subject_set

  fetchSubjectSetBySubjectId: (workflow_id, subject_set_id, selected_subject_id) ->
    console.log 'fetchSubjectSetBySubjectId()'
    request = API.type("workflows").get("#{workflow_id}/subject_sets/#{subject_set_id}/subjects/#{selected_subject_id}")
    # request = API.type("subject_sets").get(subject_set_id: subject_set_id, workflow_id: workflow_id)

    @setState
      subjectSet: []
      # currentSubjectSet: null

    request.then (subject_set) =>
      console.log 'SUBJECT SET: ', subject_set
      @setState
        subjectSets: [subject_set]
        subject_set_index: 0
        subject_index: 0 #parseInt(subject_index) || 0
        # currentSubjectSet: subject_set

  fetchSubjectSets: (workflow_id, limit) ->
    if @props.overrideFetchSubjectsUrl?
      # console.log "Fetching (fake) subject sets from #{@props.overrideFetchSubjectsUrl}"
      $.getJSON @props.overrideFetchSubjectsUrl, (subject_sets) =>
        @setState
          subjectSets: subject_sets
          # currentSubjectSet: subject_sets[0]

    else
      request = API.type('subject_sets').get
        workflow_id: workflow_id
        limit: limit
        random: true

      request.then (subject_sets)=>    # DEBUG CODE


        # TODO hack to ffwd to set with child subjects:
        ind = (i for s,i in subject_sets when s.subjects[0].child_subjects?.length > 0)[0] ? 0
        console.log "setting set index: ", (i for s,i in subject_sets when s.subjects[0].child_subjects?.length > 0)
        @setState
          subjectSets: subject_sets
          subject_set_index: ind

          # currentSubjectSet: subject_sets[0]
          # currentSubject: subject_sets[0].subjects[0]
        if @fetchSubjectsCallback?
          @fetchSubjectsCallback()

    # WHY DOES THIS BREAK?
    # request.error (xhr, status, err) =>
    #   console.error "Error loading subjects: ", url, status, err.toString()

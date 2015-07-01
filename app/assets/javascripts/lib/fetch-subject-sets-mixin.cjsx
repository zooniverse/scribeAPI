API = require './api'

module.exports =
  componentDidMount: ->
    # console.log "Fetch Subjects Mixin: ", @
    subject_page = @state.subject_current_page || null
    subject_set_page = @state.subject_set_current_page || null
    if @props.query.subject_set_id
      @fetchSubjectSet @props.query.subject_set_id, @props.query.subject_index, @props.workflow.id
    else
      @fetchSubjectSets @props.workflow.id, @props.workflow.subject_fetch_limit, subject_page, subject_set_page

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

  fetchSubjectSets: (workflow_id, limit, subject_page, subject_set_page) ->
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
        random: true unless subject_set_page
        subject_page: subject_page
        subject_set_page: subject_set_page

      request.then (subject_sets)=>    # DEBUG CODE
        console.log "SUBJECTSETS from request", subject_sets
        ind = 0
        # Uncomment this to ffwd to a set with child subjects:
        # ind = (i for s,i in subject_sets when s.subjects[0].child_subjects?.length > 0)[0] ? 0
        @setState
          subjectSets: subject_sets
          subject_set_index: ind
          subject_current_page: subject_sets[0].subject_pagination_info.current_page
          subject_set_current_page: subject_sets[0].subject_set_pagination_info.current_page


          # currentSubjectSet: subject_sets[0]
          # currentSubject: subject_sets[0].subjects[0]
        if @fetchSubjectsCallback?
          @fetchSubjectsCallback()

    # WHY DOES THIS BREAK?
    # request.error (xhr, status, err) =>
    #   console.error "Error loading subjects: ", url, status, err.toString()

API = require './api'

module.exports =
  componentDidMount: ->
    if @props.query.subject_set_id
      @fetchSubjectSet @props.query.subject_set_id, @props.query.subject_index, @props.workflow.id
    else
      @fetchSubjectSets @props.workflow.id, @props.workflow.subject_fetch_limit

  fetchNextSubjectPage: (subject_set_id, workflow_id, page_number)->
    console.log 'fetchNextSubjectPage()'
    request = API.type("subject_sets").get("#{subject_set_id}", page: page_number, workflow_id: workflow_id)

    @setState
      subjectSet: []
      
    request.then (subject_set) =>
      console.log "SUBJECT SET", subject_set
      @setState
        subjectSets: subject_set
        subject_set_index: 0
        subject_index: 0
        subject_current_page: subject_set.subject_pagination_info.current_page
        total_subject_pages: subject_set.subject_pagination_info.total_pages

  orderSubjectsByOrder: (subject_sets) ->
    for subject_set in subject_sets
      subject_set.subjects = subject_set.subjects.sort (a,b) ->
        return if a.order >= b.order then 1 else -1
    subject_sets


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

        subject_sets = @orderSubjectsByOrder(subject_sets)
        ind = 0
        # Uncomment this to ffwd to a set with child subjects:
        # ind = (i for s,i in subject_sets when s.subjects[0].child_subjects?.length > 0)[0] ? 0
        @setState
          subjectSets: subject_sets
          subject_set_index: ind
          subject_current_page: subject_sets[0].subject_pagination_info.current_page
          subject_set_current_page: subject_sets[0].subject_set_pagination_info.current_page
          total_subject_pages: subject_sets[0].subject_pagination_info.total_pages

        if @fetchSubjectsCallback?
          @fetchSubjectsCallback()


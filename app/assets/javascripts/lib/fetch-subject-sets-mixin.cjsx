API = require './api'

module.exports =
  componentDidMount: ->
    console.log 'QUERY PARAMS: ', @props.query
    # if @props.query.subject_set_id
    #   @fetchSubjectSet @props.query.subject_set_id, @props.query.subject_index, @getActiveWorkflow().id
    if @props.query.subject_set_id and @props.query.selected_subject_id
      @fetchSubjectSetBySubjectId @getActiveWorkflow().id, @props.query.subject_set_id, @props.query.selected_subject_id, @props.query.page
    else
      @fetchSubjectSets @getActiveWorkflow().id, @getActiveWorkflow().subject_fetch_limit

  # this method fetches the next page of subjects in a given subject_set.
  # right now the trigger for this method is the forward or back button in the light-box
  # I am torn about whether to set the subject_index at this point? -- AMS
  fetchNextSubjectPage: (subject_set_id, workflow_id, page_number, subject_index, callback_fn) ->
    console.log 'fetchNextSubjectPage()'
    console.log 'QUERY: ', "subject_sets/#{subject_set_id}?page=#{page_number}&workflow_id=#{workflow_id}"
    request = API.type("subject_sets").get("#{subject_set_id}", page: page_number, workflow_id: workflow_id)

    @setState
      subjectSet: []

    request.then (subject_set) =>
      console.log 'fetchNextSubjectPage() callback!'
      callback_fn()? # fixes weird pagination bugs; not too happy about this one --STI
      @setState
        subjectSets: subject_set
        subject_set_index: 0
        subject_index: subject_index || 0 # not sure that subject_index should be set here.
        subject_current_page: subject_set.subject_pagination_info.current_page
        total_subject_pages: subject_set.subject_pagination_info.total_pages

  fetchSubjectSetBySubjectId: (workflow_id, subject_set_id, selected_subject_id, page) ->
    console.log 'fetchSubjectSetBySubjectId()'
    console.log 'THE QUERY: ', "/workflows/#{workflow_id}/subject_sets/#{subject_set_id}/subjects/#{selected_subject_id}"
    request = API.type('workflows').get("#{workflow_id}/subject_sets/#{subject_set_id}/subjects/#{selected_subject_id}?page=#{page}")
    # request = API.type("subject_sets").get(subject_set_id: subject_set_id, workflow_id: workflow_id)

    @setState
      subjectSet: []
      # currentSubjectSet: null

    request.then (subject_set) =>
      console.log 'SUBJECT SET: ', subject_set

      for subject in subject_set.subjects
        console.log 'SUBJECT ID:              ', subject.id
        console.log 'SUBJECT SET: ', subject_set
        console.log 'SUBJECT ID SEARCH QUERY: ', subject_set.selected_subject_id
        if subject.id is subject_set.selected_subject_id
          console.log 'SELECTED SUBJECT ID: ', subject_set.selected_subject_id
          console.log 'MATCH!'
          subject_index = subject_set.subjects.indexOf subject

      @setState
        subjectSets: subject_set
        subject_set_index: 0
        subject_index: subject_index || 0 #parseInt(subject_index) || 0

        subject_current_page: subject_set.subject_pagination_info.current_page
        total_subject_pages: subject_set.subject_pagination_info.total_pages
        # currentSubjectSet: subject_set

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
    console.log 'fetchSubjectSets()'
    if @props.overrideFetchSubjectsUrl?
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

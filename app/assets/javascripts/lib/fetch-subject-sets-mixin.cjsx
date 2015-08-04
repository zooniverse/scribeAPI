API = require './api'

# TODO PB: There are like sixteen different ways to do the same thing in here; Should simplify

module.exports =
  componentDidMount: ->
    if @props.params.subject_set_id
      if @props.params.selected_subject_id
        @fetchSubjectSetBySubjectId @getActiveWorkflow().id, @props.params.subject_set_id, @props.params.selected_subject_id, @props.params.page ? 1
      else if @props.query.selected_subject_id
        @fetchSubjectSet @props.query.selected_subject_id, @getActiveWorkflow().id
      else
        @fetchSubjectSet @props.params.subject_set_id, @getActiveWorkflow().id

    else
      console.log 'Fetching some subject set...'
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
      for subject in subject_set.subjects
        if subject.id is subject_set.selected_subject_id
          subject_index = subject_set.subjects.indexOf subject

      @setState
        subjectSets: subject_set
        subject_set_index: 0
        subject_index: subject_index || 0 #parseInt(subject_index) || 0
        subject_current_page: subject_set.subjects_pagination_info.current_page
        total_subject_pages: subject_set.subjects_pagination_info.total_pages
        currentSubjectSet: subject_set

  orderSubjectsByOrder: (subject_sets) ->
    for subject_set in subject_sets
      subject_set.subjects = subject_set.subjects.sort (a,b) ->
        return if a.order >= b.order then 1 else -1
    subject_sets

  fetchSubjectSet: (subject_set_id, workflow_id)->
    console.log 'fetchSubjectSet()'
    request = API.type("subject_sets").get(subject_set_id: subject_set_id, workflow_id: workflow_id)

    @setState
      subjectSet: []
      # currentSubjectSet: null

    request.then (subject_set) =>
      @setState
        subjectSet: subject_set
        subjectSets: subject_set
        subject_set_index: 0
        subject_index: 0 #parseInt(subject_index) || 0
          , => console.log 'STATE: ', @state

  fetchSubjectSets: (workflow_id, limit) ->
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
        meta = subject_sets[0].getMeta

        subject_sets = @orderSubjectsByOrder(subject_sets)
        ind = 0
        # Uncomment this to ffwd to a set with child subjects:
        # ind = (i for s,i in subject_sets when s.subjects[0].child_subjects?.length > 0)[0] ? 0
        @setState
          subjectSets: subject_sets
          subject_set_index: ind
          subject_current_page: subject_sets[0].getMeta("current_page")
          subject_set_current_page: subject_sets[0].getMeta("current_page")
          total_subject_pages: subject_sets[0].getMeta("total_pages")

        if @fetchSubjectsCallback?
          @fetchSubjectsCallback()

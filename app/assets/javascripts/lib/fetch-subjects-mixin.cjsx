API = require './api'

module.exports =
  componentDidMount: ->

    # Fetching a single subject?
    if @props.params.subject_id?
      @fetchSubject @props.params.subject_id

    # Fetching subjects by current workflow and optional filters:
    else
      # Gather filters by which to query subjects
      params =
        parent_subject_id:        @props.params.parent_subject_id
        group_id:                 @props.query.group_id ? null
        subject_set_id:           @props.query.subject_set_id ? null
      @fetchSubjects params

  orderSubjectsByY: (subjects) ->
    subjects.sort (a,b) ->
      # If a is positioned vertically adjacent to b, then order by x:
      if Math.abs(a.region.y - b.region.y) <= a.region.height / 2
        if a.region.x > b.region.x then 1 else -1
      # Otherwise just order by y:
      else
        if a.region.y >= b.region.y then 1 else -1


  # Fetch a single subject:
  fetchSubject: (subject_id)->
    request = API.type("subjects").get subject_id

    @setState
      subject: []

    request.then (subject) =>
      @setState
        subject_index: 0
        subjects: [subject],
        () =>
          if @fetchSubjectsCallback?
            @fetchSubjectsCallback()

  fetchSubjects: (params, callback) ->
    _params = $.extend({
      workflow_id: @getActiveWorkflow().id
      limit: @getActiveWorkflow().subject_fetch_limit
    }, params)
    API.type('subjects').get(_params).then (subjects) =>
      if subjects.length is 0
        @setState noMoreSubjects: true

      else
        @setState
          subject_index: 0
          subjects: subjects
          subjects: @orderSubjectsByY(subjects)
          subjects_next_page: subjects[0].getMeta("next_page")

      # Does including instance have a defined callback to call when new subjects received?
      if @fetchSubjectsCallback?
        @fetchSubjectsCallback()


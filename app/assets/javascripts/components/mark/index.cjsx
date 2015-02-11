# @cjsx React.DOM
React         = require 'react'
SubjectViewer = require '../subject-viewer'
tools         = require './tools'

Mark = React.createClass # rename to Classifier
  displayName: 'Mark'

  getInitialState: ->
    console.log 'MARK WORKFLOW: ', @props.workflow
    workflow = @props.workflow
    currentTask = workflow.tasks[ workflow.first_task ]
    
    workflow: workflow
    firstTask: true
    currentTask: currentTask
    currentTool: currentTask.tool

  componentDidMount: ->
    console.log 'componentDidMount()'

    if @state.firstTask?
        console.log 'first task is: ', @state.workflow.tasks[ @state.workflow.first_task ].tool
      # console.log 'TOOLS: ', tools[@state.task.tool]
      # @setState currentTool: tools. 

  render: ->
    console.log 'first task is: ', console.log 'first task is: ', @state.workflow.tasks[ @state.workflow.first_task ].tool

    return null
    # <SubjectViewer
    #   endpoint={"/workflows/#{@state.workflow.id}/subjects.json?limit=5"} 
    #   workflow={@props.workflow} 
    #   tool={@state.currentTool} />

module.exports = Mark
window.React = React

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
##################################################################################
# ////////////////////////////////////////////////////////////////////////////////

Foo = React.createClass
  displayName: 'SubjectViewer'
  resizing: false

  getInitialState: ->
    subjects: null
    subject: null
    subjectEndpoint: @props.endpoint
    marks: []
    tools: []
    loading: false
    frame: 0
    imageWidth: 0
    imageHeight: 0
    viewX: 0
    viewY: 0
    viewWidth: 0
    viewHeight: 0
    classification: null
    selectedMark: null # TODO: currently not in use
    showTranscribeTool: false

  getFakeSubject: (group) ->
    if group is "transcribe"
      transcriptionSubject = "THIS IS A TRANSCRIPTION SUBJECT"
      return transcriptionSubject
    if group is "mark"
      markingSubject = "THIS IS A MARKING SUBJECT"
      return markingSubject

  componentDidMount: ->
    @setView 0, 0, @state.imageWidth, @state.imageHeight
    @fetchSubjects(@state.subjectEndpoint)
    window.addEventListener "resize", this.updateDimensions

  componentWillMount: ->
    @updateDimensions()

  componentWillUnmount: ->
    window.removeEventListener "resize", this.updateDimensions

  updateDimensions: ->
    @setState
      windowInnerWidth: window.innerWidth
      windowInnerHeight: window.innerHeight

  fetchSubjects: (endpoint) ->
    $.ajax
      url: endpoint
      dataType: "json"
      success: ((data) ->
        # DEBUG CODE
        # console.log 'FETCHED SUBJECTS: ', data

        @setState
          subjects: data
          subject: data[0], =>
            @state.classification = new Classification @state.subject
            @loadImage @state.subject.location

        # console.log 'Fetched Images.' # DEBUG CODE

        return
      ).bind(this)
      error: ((xhr, status, err) ->
        console.error "Error loading subjects: ", @props.endpoint, status, err.toString()
        return
      ).bind(this)
    return

  loadImage: (url) ->
    # console.log 'Loading image...' # DEBUG CODE
    @setState loading: true, =>
      img = new Image()
      img.src = url
      img.onload = =>
        if @isMounted()
          @setState
            url: url
            imageWidth: img.width
            imageHeight: img.height
            loading: false #, =>
            # console.log @state.loading
            # console.log "Finished Loading."

  prepareClassification: ->
    console.log 'prepareClassification()'
    for mark in [ @state.marks... ]
      @state.classification.annotate
        timestamp: mark.timestamp
        key: mark.key
        y_upper: mark.yUpper
        y_lower: mark.yLower
        x: mark.x
        y: mark.y

    # DEBUG CODE
    # console.log @state.classification.annotations

  submitMark: (key) ->
    # prepare classification
    mark = @state.marks[key]

    classification = new Classification @state.subject
    classification.annotate mark

    @disableMarkButton(key)

    # TODO: replace with this
    # @state.classification.send()

    # send classification
    $.post('/classifications', { 
        workflow_id: WORKFLOW_ID
        subject_id:  @state.subject.id
        location:    @state.subject.location
        annotations: classification.annotations
        started_at:  classification.started_at
        finished_at: classification.finished_at
        subject:     classification.subject
        user_agent:  classification.user_agent
      }, )
      .done (response) =>
        console.log "Success" #, response._id.$oid
        @setTranscribeSubject(key, response._id.$oid)
        @enableMarkButton(key)
        return
      .fail =>
        console.log "Failure"
        return
      # .always ->
      #   console.log "Always"
      #   return

  setTranscribeSubject: (key, transcribe_id) ->
    marks = @state.marks
    marks[key].transcribe_id = transcribe_id
    @setState marks: marks

  disableMarkButton: (key) ->
    marks = @state.marks
    marks[key].buttonDisabled = true
    @setState marks: marks
    @forceUpdate()

  enableMarkButton: (key) ->
    marks = @state.marks
    marks[key].buttonDisabled = false
    @setState marks: marks
    @forceUpdate()

  nextSubject: () ->

    @prepareClassification()
    @sendMarkClassification()

    # # DEBUG CODE
    # console.log 'CLASSIFICATION: ', @state.classification

    # console.log JSON.stringify @state.classification # DEBUG CODE
    @state.classification.send()
    @setState
      marks: [] # clear marks for next subject

    # prepare new classification
    if @state.subjects.shift() is undefined or @state.subjects.length <= 0
      @fetchSubjects(@state.subjectEndpoint)
      return
    else
      @setState subject: @state.subjects[0], =>
        @loadImage ((if @usingFakeSubject() then @state.subject.classification.subject.location else @state.subject.location))

    @state.classification = new Classification @state.subject

  handleInitStart: (e) ->
    # console.log 'handleInitStart()'

    {horizontal, vertical} = @getScale()
    rect = @refs.sizeRect?.getDOMNode().getBoundingClientRect()
    timestamp = (new Date).toUTCString()
    key = @state.marks.length
    {x, y} = @getEventOffset e
    yUpper = Math.round( y - 50/2 )
    yLower = Math.round( y + 50/2 )
    buttonDisabled = false

    marks = @state.marks
    marks.push {yUpper, yLower, x, y, key, timestamp, buttonDisabled}

    @setState
      marks:        marks
      offset:       $(e.nativeEvent.target).offset()
      selectedMark: @state.marks[@state.marks.length-1]

  handleInitDrag: (e) ->
    # console.log 'handleInitDrag()'

    {x,y} = @getEventOffset e

    dist = Math.abs( @state.selectedMark.y - y )

    if dist > 50/2
      currentMark = @state.selectedMark
      currentMark.yUpper = currentMark.y - dist
      currentMark.yLower = currentMark.y + dist
      currentMark.markHeight = currentMark.yLower - currentMark.yUpper

      @setState
        selectedMark: currentMark

  handleInitRelease: (e) ->
    # console.log 'handleInitRelease()'

  handleToolMouseDown: ->
    # console.log 'handleToolMouseDown()'

  handleMarkClick: (mark, e) ->
    {x,y} = @getEventOffset e

    @setState
      selectedMark: mark
      markOffset: {
        x: mark.x - x,
        y: mark.y - y
      }, =>
        @forceUpdate()

  handleDragMark: (e) ->
    # console.log 'handleDragMark()'
    # return unless @state.workflow is "mark"

    {x,y} = @getEventOffset e

    currentMark = @state.selectedMark
    currentMark.x = Math.round x + @state.markOffset.x
    currentMark.y = Math.round y + @state.markOffset.y
    markHeight = currentMark.yLower - currentMark.yUpper
    currentMark.yUpper = Math.round currentMark.y - markHeight/2
    currentMark.yLower = Math.round currentMark.y + markHeight/2

    # prevent dragging mark beyond image bounds
    offset = @state.markOffset.y
    return if ( y + offset - markHeight/2 ) < 0
    return if ( y + offset + markHeight/2 ) > @state.imageHeight

    @setState
      selectedMark: currentMark

  handleUpperResize: (e) ->
    # console.log 'handleUpperResize()'
    {x,y} = @getEventOffset e

    x = Math.round x
    y = Math.round y

    currentMark = @state.selectedMark

    # enforce bounds
    if y < 0
      y = 0
      return

    if currentMark.yLower - y < 50
      currentMark.yUpper = Math.round( -50 + currentMark.yLower )
      @setState selectedMark: currentMark
      return

    dy = currentMark.yUpper - y
    yUpper_p = y
    markHeight_p = currentMark.yLower - currentMark.yUpper + dy
    y_p = yUpper_p + markHeight_p/2

    currentMark.yUpper = yUpper_p
    currentMark.markHeight = markHeight_p
    currentMark.y = y_p

    @setState
      selectedMark: currentMark

  handleLowerResize: (e) ->
    # console.log 'handleLowerResize()'
    {x,y} = @getEventOffset e

    x = Math.round x
    y = Math.round y

    currentMark = @state.selectedMark

    # enforce bounds
    if y > @state.imageHeight
      y = @state.imageHeight
      return

    if y - currentMark.yUpper < 50
      currentMark.yLower = Math.round( 50 + currentMark.yUpper )
      @setState selectedMark: currentMark
      return

    dy = y - currentMark.yLower
    yLower_p = y
    markHeight_p = currentMark.yLower - currentMark.yUpper + dy
    y_p = yLower_p - markHeight_p/2

    currentMark.yLower = yLower_p
    currentMark.markHeight = markHeight_p
    currentMark.y = y_p

    @setState
      selectedMark: currentMark

  setView: (viewX, viewY, viewWidth, viewHeight) ->
    @setState {viewX, viewY, viewWidth, viewHeight}

  getScale: ->
    rect = @refs.sizeRect?.getDOMNode().getBoundingClientRect()
    rect ?= width: 0, height: 0

    horizontal: rect.width / @state.imageWidth
    vertical: rect.height / @state.imageHeight

  getEventOffset: (e) ->
    rect = @refs.sizeRect.getDOMNode().getBoundingClientRect()

    # console.log 'RECT: ', rect
    {horizontal, vertical} = @getScale()
    x: ((e.pageX - pageXOffset - rect.left) / horizontal) + @state.viewX
    y: ((e.pageY - pageYOffset - rect.top) / vertical) + @state.viewY

    # x: ((e.pageX - pageXOffset - rect.left)) + @state.viewX
    # y: ((e.pageY - pageYOffset - rect.top)) + @state.viewY

  onClickDelete: (key) ->
    marks = @state.marks
    marks.splice(key,1) # delete marks[key]
    @setState
      marks: marks
      selectedMark: null, =>
        @forceUpdate() # make sure keys are up-to-date before re-render

  beginTextEntry: ->
    # console.log 'beginTextEntry()'
    @nextSubject()
    return # just load next subject for now
    return unless @state.marks.length > 0
    @setState
      selectedMark: @state.marks[0], =>
        {horizontal, vertical} = @getScale()
        $('html, body').animate scrollTop: vertical*@state.selectedMark.y-window.innerHeight/2+80, 500

  nextTextEntry: ->
    key = @state.selectedMark.key
    if key+1 > @state.marks.length-1
      # console.log "That's all the marks for now!"
      return

    @setState selectedMark: @state.marks[key+1], =>
      {horizontal, vertical} = @getScale()
      $('html, body').animate scrollTop: vertical*@state.selectedMark.y-window.innerHeight/2+80, 500

  onClickTranscribe: (key) ->
    console.log 'onClickTranscribe() '

    console.log location.host + "/?subject_id=#{@state.marks[key].transcribe_id}#/transcribe"
    location.replace 'http://' + location.host + "/?subject_id=#{@state.marks[key].transcribe_id}&scrollOffset=#{$(window).scrollTop()}#/transcribe"
    # @setState showTranscribeTool: true

  # dummy placeholder
  recordTranscription: ->
    console.log 'recordTranscription()'

  # "https://zooniverse-static.s3.amazonaws.com/scribe_subjects/logbookofalfredg1851unse_0083.jpg"

  render: ->
    # don't render if ya ain't got subjects (yet)
    # console.log 'showTranscribeTool is ', @state.showTranscribeTool
    return null if @state.subjects is null or @state.subjects.length is 0

    viewBox = [0, 0, @state.imageWidth, @state.imageHeight]

    # LOADING
    if @state.loading
      <div className="subject-container">
        <div className="marking-surface">
          <LoadingIndicator/>
        </div>
        <p>{@state.subjects.location}</p>
        <div className="subject-ui">
          <ActionButton loading={@state.loading} />
        </div>
      </div>

    else

      if @state.marks.length is 0
        action_button =  <ActionButton label={"NEXT PAGE"} onActionSubmit={@nextSubject} />
      else if @state.workflow is "finished"
        action_button =  <ActionButton label={"FINISH"} onActionSubmit={@nextSubject} />

      else if @state.marks.length > 0
        action_button =  <ActionButton label={"FINISHED MARKING"} onActionSubmit={@beginTextEntry} />

      <div className="subject-container">
        <div className="marking-surface">

          <svg
            className = "subject-viewer-svg"
            width = {@state.imageWidth}
            height = {@state.imageHeight}
            viewBox = {viewBox}
            data-tool = {@props.selectedDrawingTool?.type} >

            <rect
              ref = "sizeRect"
              width = {@state.imageWidth}
              height = {@state.imageHeight} />

            <Draggable
              onStart = {@handleInitStart}
              onDrag  = {@handleInitDrag}
              onEnd   = {@handleInitRelease} >
              <SVGImage
                src = {@state.subject.location}
                width = {@state.imageWidth}
                height = {@state.imageHeight} />
            </Draggable>
            
            { @state.marks.map ((mark, i) ->
                <TextRowTool
                  key = {i}
                  mark = {mark}
                  imageWidth = {@state.imageWidth}
                  imageHeight = {@state.imageHeight}
                  getEventOffset = {@getEventOffset}
                  selected = {mark is @state.selectedMark}
                  onClickDelete = {@onClickDelete}
                  onClickTranscribe = {@onClickTranscribe}
                  submitMark = {@submitMark}
                  scrubberWidth = {64}
                  scrubberHeight = {32}
                  handleDragMark = {@handleDragMark}
                  handleUpperResize = {@handleUpperResize}
                  handleLowerResize = {@handleLowerResize}
                  handleMarkClick = {@handleMarkClick.bind null, mark}
                />
              ), @
            }

          </svg>

          { if @state.showTranscribeTool
            <TranscribeTool 
              transcribeSteps={transcribeSteps} 
              recordTranscription={@recordTranscription}
              nextTextEntry={@nextTextEntry}
              nextSubject = {@nextSubject}
              selectedMark={@state.selectedMark}
              xScale={@getScale().horizontal}
              yScale={@getScale().vertical}
            />          
          }

        </div>
        <p>{@state.subject.location}</p>
        <div className="subject-ui">
          {action_button}
        </div>
      </div>

# module.exports = Foo
# window.React = React

# @cjsx React.DOM

React                         = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
example_subjects              = require '../lib/example_subject.json'
SVGImage                      = require './svg-image'
Draggable                     = require '../lib/draggable'
LoadingIndicator              = require './loading-indicator'
SubjectMetadata               = require './subject-metadata'
ActionButton                  = require './action-button'
TextRegionTool                = require './text-region'
TextEntryTool                = require './text-entry'
PointTool                     = require './point'
Classification                = require '../models/classification'

ImageSubjectViewer = React.createClass # rename to Classifier
  displayName: 'ImageSubjectViewer'

  render: ->
    endpoint = "http://localhost:3000/workflows/533cd4dd4954738018030000/subjects.json?limit=5"
    <div className="image-subject-viewer">
      <SubjectViewer endpoint=endpoint />
    </div>

SubjectViewer = React.createClass
  displayName: 'SubjectViewer'

  getInitialState: ->
    subjects: example_subjects # TODO: need to remove this

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

    workflow: "text-region"

    classification: null

    selectedMark: null # TODO: currently not in use

  componentDidMount: ->
    @setView 0, 0, @state.imageWidth, @state.imageHeight
    @fetchSubjects()

    window.addEventListener "resize", this.updateDimensions

  componentWillMount: ->
    @updateDimensions()

  componentWillUnmount: ->
    window.removeEventListener "resize", this.updateDimensions

  updateDimensions: ->
    console.log 'updating dimensions'
    @setState
      windowInnerWidth: window.innerWidth
      windowInnerHeight: window.innerHeight

  fetchSubjects: ->
    $.ajax
      url: @props.endpoint
      dataType: "json"
      success: ((data) ->
        # DEBUG CODE
        # console.log 'FETCHED SUBJECTS: ', subject.location for subject in data

        @setState subjects: data, =>
          @state.classification = new Classification @state.subjects[0]
          @loadImage @state.subjects[0].location

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

  nextSubject: () ->
    for mark in [ @state.marks... ]
      @state.classification.annotate
        timestamp: mark.timestamp
        y_upper: mark.yUpper
        y_lower: mark.yLower

    # # DEBUG CODE  
    # console.log 'CLASSIFICATION: ', @state.classification

    console.log JSON.stringify @state.classification # DEBUG CODE
    @state.classification.send()
    @setState
      workflow: "text-region"
      marks: [] # clear marks for next subject

    # prepare new classification
    if @state.subjects.shift() is undefined or @state.subjects.length <= 0
      @fetchSubjects()
      return
    else
      @loadImage @state.subjects[0].location

    @state.classification = new Classification @state.subjects[0]

  handleInitStart: (e) ->
    # console.log 'handleInitStart()'

    return if @state.workflow is "text-entry"

    {horizontal, vertical} = @getScale()
    rect = @refs.sizeRect?.getDOMNode().getBoundingClientRect()
    timestamp = (new Date).toUTCString()
    key = @state.marks.length
    {x, y} = @getEventOffset e
    yUpper = y-50/2
    yLower = y+50/2

    marks = @state.marks
    marks.push {yUpper, yLower, x, y, key, timestamp}

    @setState 
      marks: marks
      offset: $(e.nativeEvent.target).offset()

    @selectMark @state.marks[@state.marks.length-1]

  handleInitDrag: (e) ->
    # console.log 'handleInitDrag()'

    return unless @state.workflow is "text-region"
    {x,y} = @getEventOffset e

    dist = Math.abs( @state.selectedMark.y - y )

    if dist > 50/2
      currentMark = @state.selectedMark
      currentMark.yUpper = currentMark.y - dist
      currentMark.yLower = currentMark.y + dist

      @setState
        selectedMark: currentMark, =>
          console.log 'STATE: ', @state.selectedMark

  handleInitRelease: (e) ->
    # console.log 'handleInitRelease()'

  handleToolMouseDown: ->
    # console.log 'handleToolMouseDown()'

  handleMarkClick: (e, mark) ->
    @selectMark mark

  handleDragMark: (e) ->
    console.log 'handleDragMark()'
    return unless @state.workflow is "text-region"
    
    {x,y} = @getEventOffset e

    # # DEBUG CODE
    # console.log "DRAG (#{x},#{y})"
    # console.log 'SELECTED MARK CENTER: ', @state.selectedMark.y
    # console.log 'SELECTED MARK DISTANCE FROM CENTER: ', Math.abs( @state.selectedMark.y - y )

    currentMark = @state.selectedMark
    currentMark.x = Math.round x
    currentMark.y = Math.round y
    markHeight = currentMark.yLower - currentMark.yUpper

    # prevent dragging mark beyond image bounds
    return if (y-markHeight/2) < 0 
    return if (y+markHeight/2) > @state.imageHeight

    @setState 
      selectedMark: currentMark, =>
        # # DEBUG CODE
        # console.log 'STATE: ', @state.selectedMark

  handleUpperResize: (e) ->
    {x,y} = @getEventOffset e

    # prevent dragging mark beyond image bounds
    return if y < 0 
    return if y > @state.imageHeight

    currentMark = @state.selectedMark
    markHeight = currentMark.yLower - currentMark.yUpper
    offset = Math.round( y - currentMark.yUpper )

    currentMark.yUpper = Math.round( Math.abs( y  + offset ) )

    @setState
      markHeight: Math.round( Math.abs( currentMark.yLower - currentMark.yUpper ) )
      selectedMark: currentMark

  handleLowerResize: (e) ->
    {x,y} = @getEventOffset e

    x = Math.round x
    y = Math.round y

    # prevent dragging mark beyond image bounds
    return if y < 0 
    return if y > @state.imageHeight

    currentMark = @state.selectedMark


    dist = Math.abs( @state.selectedMark.y - y )

    # if dist < 50/2
    #   console.log 'SBAKLJSHKLJSHKLAJHSKLJHDKLJ'
    #   currentMark = @state.selectedMark
    #   currentMark.yUpper = currentMark.y - dist
    #   currentMark.yLower = currentMark.y + dist
    # else
    
    offset = Math.round( y - currentMark.yLower )
    markHeight = currentMark.yLower - currentMark.yUpper
    
    # currentMark.yUpper = Math.round y
    currentMark.yLower = Math.round( Math.abs( y + markHeight/2 + offset ) )

    console.log 'CURRENT MARK: ', @state.selectedMark, 'OFFSET: ', offset, 'MARK HEIGHt: ', currentMark.yLower - currentMark.yUpper

    @setState
      # markHeight: Math.round( Math.abs( currentMark.yLower - currentMark.yUpper ) )
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

  selectMark: (mark) ->
    return if mark is @state.selectedMark
    @setState selectedMark: mark

  onClickDelete: (key) ->
    marks = @state.marks
    for mark, i in [ marks... ]
      if mark.key is key
        marks.splice(i, 1)
    @setState marks: marks

  beginTextEntry: ->
    console.log 'beginTextEntry()'
    return unless @state.marks.length > 0
    @setState
      workflow: "text-entry"
      selectedMark: @state.marks[0], =>
        console.log 'SELECTED MARK: ', @state.selectedMark
        {horizontal, vertical} = @getScale()
        $('html, body').animate scrollTop: vertical*@state.selectedMark.y-window.innerHeight/2+80, 500

  nextTextEntry: ->
    console.log "nextTextEntry()"

    key = @state.selectedMark.key
    if key+1 > @state.marks.length-1
      console.log "That's all the marks for now!"
      @setState workflow: "finished"
      return

    @setState selectedMark: @state.marks[key+1], =>
      console.log 'SELECTED MARK: ', @state.selectedMark
      {horizontal, vertical} = @getScale()
      $('html, body').animate scrollTop: vertical*@state.selectedMark.y-window.innerHeight/2+80, 500

  render: ->
    console.log 'subject-viewer render():'
    viewBox = [0, 0, @state.imageWidth, @state.imageHeight]

    # LOADING
    if @state.loading
      <div className="subject-container">
        <div className="marking-surface">
          <LoadingIndicator/>
        </div>
        <p>{@state.subjects[0].location}</p>
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

        if @state.workflow is "text-entry"
          action_button = <ActionButton label={"NEXT"} onActionSubmit={@nextTextEntry} />
        else
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
                src = {@state.subjects[0].location}
                width = {@state.imageWidth}
                height = {@state.imageHeight} />
            </Draggable>

            { @state.marks.map ((mark, i) ->

              <TextRegionTool
                key = {mark.key}
                mark = {mark}
                disabled = {false}
                imageWidth = {@state.imageWidth}
                imageHeight = {@state.imageHeight}
                getEventOffset = {@getEventOffset}
                select = {@selectMark.bind null, mark}
                selected = {mark is @state.selectedMark}
                onClickDelete = {@onClickDelete}
                scrubberWidth = {64}
                scrubberHeight = {16}
                workflow = {@state.workflow}
                handleDragMark = {@handleDragMark}
                handleUpperResize = {@handleUpperResize}
                handleLowerResize = {@handleLowerResize}
                handleMarkClick = {@handleMarkClick.bind null, mark}
              >
              </TextRegionTool>
            ), @}


          </svg>

          { if @state.workflow is "text-entry"
            <TextEntryTool
              top={ @getScale().vertical * @state.selectedMark.yLower + 20 + @state.offset.top }
              left={@state.windowInnerWidth/2 - 200}
            />
          }

        </div>
        <p>{@state.subjects[0].location}</p>
        <div className="subject-ui">
          {action_button}
        </div>
      </div>

module.exports = ImageSubjectViewer
window.React = React

# @cjsx React.DOM

React                         = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
SVGImage                      = require './svg-image'
Draggable                     = require '../lib/draggable'
LoadingIndicator              = require './loading-indicator'
SubjectMetadata               = require './subject-metadata'
ActionButton                  = require './action-button'
Classification                = require '../models/classification'

SubjectViewer = React.createClass
  displayName: 'SubjectViewer'
  resizing: false

  getInitialState: ->
    # # DEBUG CODE
    # console.log 'USING ENDPOINT: ', @props.endpoint
    imageWidth: 0
    imageHeight: 0
    
    subjectEndpoint: @props.endpoint
    subjects: null
    subject: null
    classification: null
    tool: @props.tool

    marks: []

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

  fetchSubjects: ->
    $.ajax
      url: @state.subjectEndpoint
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
        console.error "Error loading subjects: ", @state.subjectEndpoint, status, err.toString()
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

  # VARIOUS EVENT HANDLERS

  handleInitStart: (e) ->
    console.log 'handleInitStart() '
    marks = @state.marks
    mark = 
      x: @getEventOffset(e).x
      y: @getEventOffset(e).y
      scale: @getScale()
      timestamp: (new Date).toJSON()

    marks.push mark

    @setState marks: marks, =>
      console.log 'MARKS: ', @state.marks

  handleInitDrag: (e) ->
    console.log 'handleInitDrag()'

  handleInitRelease: (e) ->
    console.log 'handleInitRelease()'

  handleToolMouseDown: (e) ->
    console.log 'handleToolMouseDown()'

  setView: (viewX, viewY, viewWidth, viewHeight) ->
    @setState {viewX, viewY, viewWidth, viewHeight}

  getScale: ->
    rect = @refs.sizeRect?.getDOMNode().getBoundingClientRect()
    rect ?= width: 0, height: 0

    horizontal: rect.width / @state.imageWidth
    vertical: rect.height / @state.imageHeight

  getEventOffset: (e) ->
    rect = @refs.sizeRect.getDOMNode().getBoundingClientRect()
    {horizontal, vertical} = @getScale()
    x: ((e.pageX - pageXOffset - rect.left) / horizontal) + @state.viewX
    y: ((e.pageY - pageYOffset - rect.top) / vertical) + @state.viewY

  render: ->
    return null if @state.subjects is null or @state.subjects.length is 0
    viewBox = [0, 0, @state.imageWidth, @state.imageHeight]

    ToolComponent = @state.tool
    
    if @state.loading
      markingSurfaceContent = <LoadingIndicator />
    else
      markingSurfaceContent =  
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

          { @state.marks.map ((mark, key) ->
              <ToolComponent key={key} mark={mark} getEventOffset={@getEventOffset} />
            ), @
          }

        </svg>

    <div className="subject-viewer">
      <div className="subject-container">
        <div className="marking-surface">
          {markingSurfaceContent}
        </div>
        <p>{@state.subjects.location}</p>
        <div className="subject-ui">
          <ActionButton loading={@state.loading} />
        </div>
      </div>
    </div>

module.exports = SubjectViewer
window.React = React

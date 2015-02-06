# @cjsx React.DOM

React                         = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
example_subjects              = require '../lib/example_subject.json'
SVGImage                      = require './svg-image'
Draggable                     = require '../lib/draggable'
LoadingIndicator              = require './loading-indicator'
SubjectMetadata               = require './subject-metadata'
ActionButton                  = require './action-button'
TextRowTool                   = require './mark/text-row-tool'
TranscribeTool                = require './transcribe/transcribe-tool'
Classification                = require '../models/classification'

WORKFLOW_ID = '54b82b4745626f20c9020000' # marking workflow
endpoint = "/workflows/#{WORKFLOW_ID}/subjects.json?limit=5"

SubjectViewer = React.createClass
  displayName: 'SubjectViewer'
  resizing: false

  getInitialState: ->
    subjects: null
    subject: null
    subjectEndpoint: endpoint
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

  handleInitStart: (e) ->
    console.log 'handleInitStart()'
    
  handleInitDrag: (e) ->
    console.log 'handleInitDrag()'

  handleInitRelease: (e) ->
    console.log 'handleInitRelease()'

  handleToolMouseDown: ->
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
    if @state.loading
      <div className="subject-viewer">
        <div className="subject-container">
          <div className="marking-surface">
            <LoadingIndicator/>
          </div>
          <p>{@state.subjects.location}</p>
          <div className="subject-ui">
            <ActionButton loading={@state.loading} />
          </div>
        </div>
      </div>
    else
      action_button =  <ActionButton label={"NEXT PAGE"} onActionSubmit={@nextSubject} />  
      <div className="subject-viewer">
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
            </svg>
          </div>
          <p>{@state.subject.location}</p>
          <div className="subject-ui">
            {action_button}
          </div>
        </div>
      </div>

module.exports = SubjectViewer
window.React = React

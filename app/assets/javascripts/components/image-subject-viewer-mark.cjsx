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
# TextEntryTool                 = require './text-entry'
RegionFocusTool               = require './region-focus'
PointTool                     = require './point'
Classification                = require '../models/classification'
getUrlParamByName             = require '../lib/getUrlParamByName'


ImageSubjectViewer_mark = React.createClass # rename to Classifier
  displayName: 'ImageSubjectViewer_mark'

  render: ->
    endpoint = "http://localhost:3000/workflows/533cd4dd4954738018030000/subjects.json?limit=5"
    <div className="image-subject-viewer">
      <SubjectViewer endpoint=endpoint task={@props.task} />
    </div>

  # componentDidMount: ->
  #   console.log 'TASK: ', @props.task


SubjectViewer = React.createClass
  displayName: 'SubjectViewer'

  resizing: false

  usingFakeSubject: ->
    if getUrlParamByName('use_fake_subject') is "true"
      console.log 'DEBUG NOTE: USING FAKE SUBJECTS'
      return true
    else
      return false

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

    # defines which workflow is active (mark, transcribe, etc.)
    workflow: "mark"

    classification: null

    selectedMark: null # TODO: currently not in use

  getFakeSubject: (group) ->
    if group is "transcribe"
      transcriptionSubject = "THIS IS A TRANSCRIPTION SUBJECT"
      return transcriptionSubject
    if group is "mark"
      markingSubject = "THIS IS A MARKING SUBJECT"
      return markingSubject

  componentDidMount: ->
    console.log 'TASK = ', @props.task
    @setView 0, 0, @state.imageWidth, @state.imageHeight
    
    if @usingFakeSubject()
      if @props.task is 'mark'
        console.log 'using MARKING subjects'
        subjectEndpoint = "./offline/example_subjects/marking_subjects.json"
      else 
        console.log 'using TRANSCRIPTION subjects'
        subjectEndpoint = "./offline/example_subjects/transcription_subjects.json"
      @setState subjectEndpoint: subjectEndpoint, =>
        @fetchSubjects(@state.subjectEndpoint)
    else
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
        console.log 'FETCHED SUBJECTS: ', data

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

  nextSubject: () ->
    console.log 'MARKS: ', @state.marks
    for mark in [ @state.marks... ]
      @state.classification.annotate
        timestamp: mark.timestamp
        key: mark.key
        y_upper: mark.yUpper
        y_lower: mark.yLower
        x: mark.x
        y: mark.y

    # # DEBUG CODE  
    console.log 'CLASSIFICATION: ', @state.classification

    # console.log JSON.stringify @state.classification # DEBUG CODE
    @state.classification.send()
    @setState
      workflow: "mark"
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

    return if @state.workflow is "transcribe"

    {horizontal, vertical} = @getScale()
    rect = @refs.sizeRect?.getDOMNode().getBoundingClientRect()
    timestamp = (new Date).toUTCString()
    key = @state.marks.length
    {x, y} = @getEventOffset e
    yUpper = Math.round( y - 50/2 )
    yLower = Math.round( y + 50/2 )

    marks = @state.marks
    marks.push {yUpper, yLower, x, y, key, timestamp}

    @setState 
      marks: marks
      offset: $(e.nativeEvent.target).offset()

    @selectMark @state.marks[@state.marks.length-1]

  handleInitDrag: (e) ->
    console.log 'handleInitDrag()'

    return unless @state.workflow is "mark"
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
    console.log 'handleInitRelease()'

  handleToolMouseDown: ->
    console.log 'handleToolMouseDown()'

  handleMarkClick: (mark, e) ->
    {x,y} = @getEventOffset e

    # save click offset from mark center
    @setState 
      selectedMark: mark
      markOffset: { 
        x: mark.x - x, 
        y: mark.y - y
      }

  handleDragMark: (e) ->
    console.log 'handleDragMark()'

    return unless @state.workflow is "mark"
    
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
    console.log 'handleUpperResize()'
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
    console.log 'handleLowerResize()'
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

  selectMark: (mark) ->
    return if mark is @state.selectedMark
    @setState selectedMark: mark

  onClickDelete: (key) ->
    marks = @state.marks
    for mark, i in [ marks... ]
      if mark.key is key
        marks.splice(i, 1)
    @setState 
      marks: marks
      selectedMark: null

  beginTextEntry: ->
    console.log 'beginTextEntry()'
    @nextSubject()
    return # just load next subject for now
    return unless @state.marks.length > 0
    @setState
      workflow: "transcribe"
      selectedMark: @state.marks[0], =>
        {horizontal, vertical} = @getScale()
        $('html, body').animate scrollTop: vertical*@state.selectedMark.y-window.innerHeight/2+80, 500

  nextTextEntry: ->

    key = @state.selectedMark.key
    if key+1 > @state.marks.length-1
      # console.log "That's all the marks for now!"
      @setState workflow: "finished"
      return

    @setState selectedMark: @state.marks[key+1], =>
      {horizontal, vertical} = @getScale()
      $('html, body').animate scrollTop: vertical*@state.selectedMark.y-window.innerHeight/2+80, 500

  render: ->
    # don't render if ya ain't got subjects (yet)
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

        if @state.workflow is "transcribe"
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
                src = {"https://zooniverse-static.s3.amazonaws.com/scribe_subjects/logbookofalfredg1851unse_0083.jpg"}
                width = {@state.imageWidth}
                height = {@state.imageHeight} />
            </Draggable>

            { 
              if @state.workflow is "mark"
                @state.marks.map ((mark, i) ->
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
                    scrubberHeight = {32}
                    workflow = {@state.workflow}
                    handleDragMark = {@handleDragMark}
                    handleUpperResize = {@handleUpperResize}
                    handleLowerResize = {@handleLowerResize}
                    handleMarkClick = {@handleMarkClick.bind null, mark}
                  />
                ), @
              else
                console.log 'SELECTED MARK KEY: ', @state.selectedMark.key
                <RegionFocusTool 
                  key = {@state.selectedMark.key}
                  mark = {@state.selectedMark}
                  disabled = {false}
                  imageWidth = {@state.imageWidth}
                  imageHeight = {@state.imageHeight}
                  getEventOffset = {@getEventOffset}
                  select = {@selectMark.bind null, @state.selectedMark}
                  selected = {true}
                  onClickDelete = {@onClickDelete}
                  scrubberWidth = {64}
                  scrubberHeight = {32}
                  workflow = {@state.workflow}
                  handleDragMark = {@handleDragMark}
                  handleUpperResize = {@handleUpperResize}
                  handleLowerResize = {@handleLowerResize}
                  handleMarkClick = {@handleMarkClick.bind null, @state.selectedMark}
                />
            }


          </svg>


        </div>
        <p>{@state.subject.location}</p>
        <div className="subject-ui">
          {action_button}
        </div>
      </div>

module.exports = ImageSubjectViewer_mark
window.React = React

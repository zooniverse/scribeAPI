  # @cjsx React.DOM

React                         = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
SVGImage                      = require './svg-image'
Draggable                     = require '../lib/draggable'
MouseHandler                  = require '../lib/mouse-handler'
LoadingIndicator              = require './loading-indicator'
SubjectMetadata               = require './subject-metadata'
ActionButton                  = require './action-button'
markingTools                  = require './mark/tools'

RowFocusTool                  = require 'components/row-focus-tool'

MarkDrawingMixin              = require 'lib/mark-drawing-mixin'

API = require "lib/api"

cloneWithProps = require 'react/lib/cloneWithProps'

module.exports = React.createClass
  displayName: 'SubjectViewer'
  resizing: false

  mixins: [MarkDrawingMixin] # load helper methods to draw marks and highlights

  getInitialState: ->
    imageWidth: @props.subject.width
    imageHeight: @props.subject.height
    subject: @props.subject
    marks: []
    selectedMark: null
    active: @props.active

  getDefaultProps: ->
    tool: null # Optional tool to place alongside subject (e.g. transcription tool placed alongside mark)
    onLoad: null
    annotationIsComplete: false

  componentWillReceiveProps: (new_props) ->
    # console.log "SubjectViewer#componentWillReceiveProps: ", @props, new_props
    # @setUncommittedMark null if ! @state.uncommittedMark?.saving && ! new_props.annotation?.subToolIndex?
    # @setUncommittedMark null if ! new_props.annotation?.subToolIndex?
    # console.log "setting null because",new_props.task?.tool != 'pickOneMarkOne'
    @setUncommittedMark null if new_props.task?.tool != 'pickOneMarkOne'

  componentDidMount: ->
    @setView 0, 0, @state.imageWidth, @state.imageHeight
    @loadImage @props.subject.location.standard
    window.addEventListener "resize", this.updateDimensions

  componentWillUnmount: ->
    window.removeEventListener "resize", this.updateDimensions

  updateDimensions: ->
    @setState
      windowInnerWidth: window.innerWidth
      windowInnerHeight: window.innerHeight

    if ! @state.loading && @getScale()? && @props.onLoad?
      scale = @getScale()
      props =
        size:
          w: scale.horizontal * @state.imageWidth
          h: scale.vertical * @state.imageHeight
          scale: scale

      @props.onLoad props

  loadImage: (url) ->
    @setState loading: true, =>
      img = new Image()
      img.src = url
      img.onload = =>
        # if @isMounted()

        @setState
          url: url
          # imageWidth: img.width
          # imageHeight: img.height
          loading: false
        @updateDimensions()

  # VARIOUS EVENT HANDLERS

  # Handle initial mousedown:
  handleInitStart: (e) ->

    return null if ! @props.annotation?.subToolIndex?
    subTool = @props.task.tool_config.tools[@props.annotation.subToolIndex]
    if ! subTool
      subTool
    return null if ! subTool?

    # If there's a current, uncommitted mark, commit it:
    if @state.uncommittedMark?
      @submitMark()

    # Instantiate appropriate marking tool:
    MarkComponent = markingTools[subTool.type] # NEEDS FIXING

    # Create an initial mark instance, which will soon gather coords:
    mark = toolName: subTool.type, userCreated: true, subToolIndex: @state.uncommittedMark?.subToolIndex ? @props.annotation?.subToolIndex

    mouseCoords = @getEventOffset e

    if MarkComponent.defaultValues?
      defaultValues = MarkComponent.defaultValues mouseCoords
      for key, value of defaultValues
        mark[key] = value

    # Gather initial coords from event into mark instance:
    if MarkComponent.initStart?
      initValues = MarkComponent.initStart mouseCoords, mark, e
      for key, value of initValues
        mark[key] = value

    @props.onChange? mark

    console.log "handleInitStart: ", mark
    @setUncommittedMark mark

    @selectMark mark

  # Handle mouse dragging
  handleInitDrag: (e) ->
    # console.log "handleInitDrag: ", @state.uncommittedMark
    return null if ! @state.uncommittedMark?

    mark = @state.uncommittedMark

    # Instantiate appropriate marking tool:
    MarkComponent = markingTools[mark.toolName]

    if MarkComponent.initMove?
      mouseCoords = @getEventOffset e
      initMoveValues = MarkComponent.initMove mouseCoords, mark, e
      for key, value of initMoveValues
        mark[key] = value

    @props.onChange? mark

    @setState
      uncommittedMark: mark

  # Handle mouseup at end of drag:
  handleInitRelease: (e) ->
    return null if ! @state.uncommittedMark?

    mark = @state.uncommittedMark

    # Instantiate appropriate marking tool:
    # AMS: think this is going to markingTools[mark._toolIndex]
    MarkComponent = markingTools[mark.toolName]

    if MarkComponent.initRelease?
      mouseCoords = @getEventOffset e
      initReleaseValues = MarkComponent.initRelease mouseCoords, mark, e
      for key, value of initReleaseValues
        mark[key] = value
    if MarkComponent.initValid? and not MarkComponent.initValid mark
      @destroyMark @props.annotation, mark

    @setUncommittedMark mark

  setUncommittedMark: (mark) ->
    @setState
      uncommittedMark: mark

  setView: (viewX, viewY, viewWidth, viewHeight) ->
    @setState {viewX, viewY, viewWidth, viewHeight}

  # PB This is not returning anything but 0, 0 for me; Seems like @refs.sizeRect is empty when evaluated (though nonempty later)
  getScale: ->
    rect = @refs.sizeRect?.getDOMNode().getBoundingClientRect()
    return {horizontal: 1, vertical: 1} if ! rect? || ! rect.width?
    rect ?= width: 0, height: 0
    horizontal = rect.width / @state.imageWidth
    vertical = rect.height / @state.imageHeight
    # TODO hack fallback:
    return {horizontal, vertical}

  getEventOffset: (e) ->
    rect = @refs.sizeRect.getDOMNode().getBoundingClientRect()
    scale = @getScale()
    x = ((e.pageX - pageXOffset - rect.left) / scale.horizontal) + @state.viewX
    y = ((e.pageY - pageYOffset - rect.top) / scale.vertical) + @state.viewY
    return {x, y}

  # Set mark to currently selected:
  selectMark: (mark) ->
    @setState selectedMark: mark, =>
      if mark?.details?
        @forceUpdate() # Re-render to reposition the details tooltip.

  # Destroy mark:
  destroyMark: (mark) ->
    # return
    console.log 'destroyMark()'
    marks = @state.marks

    if mark is @state.selectedMark
      marks.splice (marks.indexOf mark), 1
      @setState
        marks: marks
        selectedMark: null, => console.log 'MARKS (after): ', @state.marks

  # Commit mark
  submitMark: ->
    mark = @state.uncommittedMark

    @setUncommittedMark null

    @props.onComplete? mark

  handleChange: (mark) ->
    @setState
      selectedMark: mark
        , =>
          # console.log 'SELECTED MARK: ', mark
          @props.onChange? mark

  getCurrentMarks: ->
    console.log "getCurrentMarks @props", @props
    # Previous marks are really just the region hashes of all child subjects:
    marks = []
    for child_subject, i in @props.subject.child_subjects
      child_subject.region.subject_id = child_subject.id # copy id field into region (not ideal)
      marks[i] = child_subject.region

    # marks = (s for s in (@props.subject.child_subjects ? [] ) when s?.region?).map (m) ->
    #   # {userCreated: false}.merge
    #   m?.region ? {}

    # Here we append the currently-being-drawn mark to the list of marks, if there is one:
    marks = marks.concat @state.uncommittedMark if @state.uncommittedMark?

    marks

  render: ->
    viewBox = [0, 0, @state.imageWidth, @state.imageHeight]
    # ToolComponent = @state.tool # AMS:from classification refactor.
    scale = @getScale()

    if @props.workflow.name is 'transcribe'
      yPos = (@props.subject.data.y - @props.subject.data.height?) * @getScale().vertical - 100
      $('html, body').animate({scrollTop: yPos}, 300);

    actionButton =
      if @state.loading
        <ActionButton onAction={@nextSubject} className="disabled" text="Loading..." />
      else
        <ActionButton onClick={@nextSubject} text="Next Page" />

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
          <MouseHandler
            onStart = {@handleInitStart}
            onDrag  = {@handleInitDrag}
            onEnd   = {@handleInitRelease}
            inst    = "marking surface">
            <SVGImage
              src = {@props.subject.location.standard}
              width = {@state.imageWidth}
              height = {@state.imageHeight} />
          </MouseHandler>

          { # HIGHLIGHT SUBJECT FOR TRANSCRIPTION
            # TODO: Makr sure x, y, w, h are scaled properly
            if @props.workflow.name in ['transcribe', 'verify']
              toolName = @props.subject.region.toolName
              mark = @props.subject.region
              ToolComponent = markingTools[toolName]
              isPriorMark = true
              <g>
                { @highlightMark(mark, toolName) }
                <ToolComponent
                  key={@props.subject.id}
                  mark={mark}
                  xScale={scale.horizontal}
                  yScale={scale.vertical}
                  disabled={isPriorMark}
                  selected={mark is @state.selectedMark}
                  getEventOffset={@getEventOffset}
                  ref={@refs.sizeRect}
                  onSelect={@selectMark.bind this, @props.subject, mark}
                />
              </g>
          }

          {
            marks = @getCurrentMarks()
            for mark in marks
              mark._key ?= Math.random()

              # If mark hasn't acquired coords yet, don't draw it yet:
              continue if ! mark.x? || ! mark.y?

              isPriorMark = ! mark.userCreated

              <g key={mark._key} className="marks-for-annotation" data-disabled={isPriorMark or null}>
                {
                  # console.log 'NEW MARK: ', mark, (mark.x), (mark.y+0)
                  mark._key ?= Math.random()
                  ToolComponent = markingTools[mark.toolName]
                  <ToolComponent
                    key={mark._key}
                    subject_id={mark.subject_id}
                    mark={mark}
                    xScale={scale.horizontal}
                    yScale={scale.vertical}
                    disabled={! mark.userCreated}
                    isPriorMark={isPriorMark}
                    selected={mark is @state.selectedMark}
                    getEventOffset={@getEventOffset}
                    submitMark={@submitMark}
                    ref={@refs.sizeRect}

                    onSelect={@selectMark.bind this, mark}
                    onChange={@handleChange.bind this, mark}
                    onDestroy={@destroyMark.bind this, mark}
                  />
                }
              </g>

            }

          </svg>

    #  Render any tools passed directly in in same parent div so that we can efficiently position them with respect to marks"

    <div className="subject-viewer#{if @props.active then ' active' else ''}">
      <div className="subject-container">
        <div className="marking-surface">
          {markingSurfaceContent}
          {
            # console.log "SubjectViewer#render children: ", @props.children
            if @props.children?
              @props.children
              cloneWithProps @props.children,
                scale: scale # pass scale down to children (for transcribe tools)
               #  subject: @props.subject
          }
        </div>
      </div>
    </div>

window.React = React

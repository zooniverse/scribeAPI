React                         = require 'react/addons'
{Router, Routes, Route, Link} = require 'react-router'
SVGImage                      = require './svg-image'
MouseHandler                  = require '../lib/mouse-handler'
LoadingIndicator              = require './loading-indicator'
SubjectMetadata               = require './subject-metadata'
NextButton                    = require './action-button'
markingTools                  = require './mark/tools'

RowFocusTool                  = require 'components/row-focus-tool'

MarkDrawingMixin              = require 'lib/mark-drawing-mixin'

API = require "lib/api"

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
    if Object.keys(@props.annotation).length == 0 #prevents back-to-back mark tasks, displaying a duplicate mark from previous tasks.
      @setUncommittedMark null


  componentDidMount: ->
    @setView 0, 0, @props.subject.width, @props.subject.height
    @loadImage @props.subject.location.standard
    window.addEventListener "resize", this.updateDimensions

    # scroll to mark when transcribing
    if @props.workflow.name is 'transcribe'
      yPos = (@props.subject.data.y - @props.subject.data.height?) * @getScale().vertical - 100
      $('html, body').animate({scrollTop: yPos}, 500)

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
          w: scale.horizontal * @props.subject.width
          h: scale.vertical * @props.subject.height
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

    subToolIndex = @props.subToolIndex
    return null if ! subToolIndex?
    subTool = @props.task.tool_config?.tools?[subToolIndex]
    return null if ! subTool?

    # If there's a current, uncommitted mark, commit it:
    if @state.uncommittedMark?
      @submitMark()

    # Instantiate appropriate marking tool:
    MarkComponent = markingTools[subTool.type] # NEEDS FIXING

    # Create an initial mark instance, which will soon gather coords:
    # mark = toolName: subTool.type, userCreated: true, subToolIndex: @state.uncommittedMark?.subToolIndex ? @props.annotation?.subToolIndex
    mark =
      toolName: subTool.type
      userCreated: true
      subToolIndex: subToolIndex
      color: subTool.color # @props.annotation?.subToolIndex
      isTranscribable: true # @props.annotation?.subToolIndex

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

    @setUncommittedMark mark

    @selectMark mark

  # Handle mouse dragging
  handleInitDrag: (e) ->
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
    horizontal = rect.width / @props.subject.width
    vertical = rect.height / @props.subject.height
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
    console.log 'destroyMark(): ', mark

    marks = @state.marks

    if mark is @state.selectedMark
      marks.splice (marks.indexOf mark), 1
      @setState
        marks: marks
        selectedMark: null #, => console.log 'MARKS (after): ', @state.marks
        uncommittedMark: null
    @props.destroyCurrentClassification()

  # Commit mark
  submitMark: ->
    mark = @state.uncommittedMark
    # console.log "SubjectViewer: Submit mark: ", mark.subToolIndex, mark

    @setUncommittedMark null

    @props.onComplete? mark

  handleChange: (mark) ->
    @setState
      selectedMark: mark
        , =>
          # console.log 'SELECTED MARK: ', mark
          @props.onChange? mark

  getCurrentMarks: ->
    # Previous marks are really just the region hashes of all child subjects
    marks = []
    for child_subject, i in @props.subject.child_subjects
      child_subject.region.subject_id = child_subject.id # copy id field into region (not ideal)
      marks[i] = child_subject.region
      marks[i].isTranscribable = !child_subject.user_has_classified

    # marks = (s for s in (@props.subject.child_subjects ? [] ) when s?.region?).map (m) ->
    #   # {userCreated: false}.merge
    #   m?.region ? {}

    # Here we append the currently-being-drawn mark to the list of marks, if there is one:
    marks = marks.concat @state.uncommittedMark if @state.uncommittedMark?

    marks

  render: ->
    return null if ! @props.active

    viewBox = [0, 0, @props.subject.width, @props.subject.height]
    scale = @getScale()

    actionButton =
      if @state.loading
        <NextButton onClick={@nextSubject} disabled=true label="Loading..." />
      else
        <NextButton onClick={@nextSubject} label="Next Page" />

    if @state.loading
      markingSurfaceContent = <LoadingIndicator />
    else
      markingSurfaceContent =
        <svg
          className = "subject-viewer-svg"
          width = {@props.subject.width}
          height = {@props.subject.height}
          viewBox = {viewBox}
          data-tool = {@props.selectedDrawingTool?.type} >
          <rect
            ref = "sizeRect"
            width = {@props.subject.width}
            height = {@props.subject.height} />
          <MouseHandler
            onStart = {@handleInitStart}
            onDrag  = {@handleInitDrag}
            onEnd   = {@handleInitRelease}
            inst    = "marking surface">
            <SVGImage
              src = {@props.subject.location.standard}
              width = {@props.subject.width}
              height = {@props.subject.height} />
          </MouseHandler>

          { # HIGHLIGHT SUBJECT FOR TRANSCRIPTION
            # TODO: Makr sure x, y, w, h are scaled properly
            if @props.workflow.name in ['transcribe', 'verify']
              toolName = @props.subject.region.toolName

              mark = @props.subject.region
              console.log "MARK", mark
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
                    isTranscribable={mark.isTranscribable}
                    isPriorMark={isPriorMark}
                    subjectCurrentPage={@props.subjectCurrentPage}
                    selected={mark is @state.selectedMark}
                    getEventOffset={@getEventOffset}
                    submitMark={@submitMark}
                    sizeRect={@refs.sizeRect}

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
          { if @props.children?
              React.cloneElement @props.children,
                loading: @state.loading       # pass loading state to current transcribe tool
                scale: scale                  # pass scale down to children (for transcribe tools)
          }
        </div>
      </div>
    </div>

window.React = React

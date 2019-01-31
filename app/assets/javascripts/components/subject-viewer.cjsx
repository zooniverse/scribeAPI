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
    subject: @props.subject
    marks: @getMarksFromProps(@props)
    selectedMark: null
    active: @props.active
    zoom:
      level: 1
      x: 0
      y: 0
    scale: {horizontal: 1, vertical: 1}
    sameSessionTranscriptions: []

  getDefaultProps: ->
    tool: null # Optional tool to place alongside subject (e.g. transcription tool placed alongside mark)
    onLoad: null
    annotationIsComplete: false
    interimMarks: {}

  componentWillReceiveProps: (new_props) ->
    @setUncommittedMark null if new_props.task?.tool != 'pickOneMarkOne'

    if Object.keys(@props.annotation).length == 0 #prevents back-to-back mark tasks, displaying a duplicate mark from previous tasks.
      @setUncommittedMark null

    @setState
      marks: @getMarksFromProps(new_props)

    if new_props.subject.id == @props.subject.id
      @scrollToSubject()

  componentDidMount: ->
    @setView 0, 0, @props.subject.width, @props.subject.height
    @loadImage @props.subject.location.standard
    window.addEventListener "resize", this.updateDimensions

    $(document).keydown (e) =>
      # Handle <delete> keypress
      if e.keyCode == 46
        mark = @state.selectedMark
        @destroyMark mark if mark?

      # Handle <enter> keypress
      else if e.keyCode == 13
        @submitMark(@state.uncommittedMark) if @state.uncommittedMark?

  scrollToSubject: ->
    # scroll to mark when transcribing
    if @props.workflow.name is 'transcribe'
      yPos = (@props.subject.data.y - @props.subject.data.height?) * @state.scale.vertical - 100
      $('html, body').stop().animate({scrollTop: yPos}, 500)

  componentDidUpdate: ->
    scale = @getScale()
    changed = scale.horizontal != @state.scale.horizontal && scale.vertical != @state.scale.vertical
    if changed
      @setState scale: scale, () =>
        @updateDimensions()
        @scrollToSubject()


  componentWillUnmount: ->
    window.removeEventListener "resize", @updateDimensions

  updateDimensions: ->
    if ! @state.loading && @state.scale? && @props.onLoad?
      scale = @state.scale
      props =
        size:
          w: scale.horizontal * @props.subject.width
          h: scale.vertical * @props.subject.height

      @props.onLoad props

    # Fix for IE: On resize, manually set dims of svg because otherwise it displays as a tiny tiny thumb
    if $('.subject-viewer')
      w = parseInt($('.subject-viewer').width())
      w = Math.min w, $('body').width() - 300
      h = (w / @props.subject.width) * @props.subject.height
      $('.subject-viewer svg').width w
      $('.subject-viewer svg').height h

      # Also a fix for IE:
      @setState scale: @getScale()

  loadImage: (url) ->
    @setState loading: true, =>
      img = new Image()
      img.src = url
      img.onload = =>
        @setState
          url: url
          loading: false
          scale: @getScale(), () =>
            @updateDimensions()
            @scrollToSubject()

  # VARIOUS EVENT HANDLERS

  # Commit mark
  submitMark: (mark, oncomplete) ->
    return unless mark?
    @props.onComplete? mark
    @setUncommittedMark null, oncomplete # reset uncommitted mark

  # Handle initial mousedown:
  handleInitStart: (e) ->
    return null if e.buttons? && e.button? && e.button > 0 # ignore right-click
    newMark = @createMark(e)

    # Don't proceed as if a new mark was created if no mark was created (i.e. no drawing tool selected)
    return if ! newMark?

    # submit uncommitted mark
    if @state.uncommittedMark?
      @submitMark(@state.uncommittedMark)

    @props.onChange? newMark
    @setUncommittedMark newMark
    # @selectMark newMark

  createMark: (e) ->
    return null if ! (subToolIndex = @props.subToolIndex)?
    return null if ! (subTool = @props.task.tool_config?.options?[subToolIndex])?

    # Instantiate appropriate marking tool:
    MarkComponent = markingTools[subTool.type] # NEEDS FIXING
    return null if ! MarkComponent?

    mark =
      belongsToUser: true # let users see their current mark when hiding others
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

    return mark

  # Handle mouse dragging
  handleInitDrag: (e) ->
    return null if ! @state.uncommittedMark?
    mark = @state.uncommittedMark
    MarkComponent = markingTools[mark.toolName] # instantiate appropriate marking tool

    if MarkComponent.initMove?
      mouseCoords = @getEventOffset e
      initMoveValues = MarkComponent.initMove mouseCoords, mark, e
      for key, value of initMoveValues
        mark[key] = value


    @props.onChange? mark
    @setState uncommittedMark: mark

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

    mark.isUncommitted = true
    mark.belongsToUser = true
    @setUncommittedMark mark

  setUncommittedMark: (mark, oncomplete) ->
    @setState
      uncommittedMark: mark,
      selectedMark: mark, () =>
        oncomplete() if oncomplete?

  setView: (viewX, viewY, viewWidth, viewHeight) ->
    @setState {viewX, viewY, viewWidth, viewHeight}

  # PB This is not returning anything but 0, 0 for me; Seems like @refs.sizeRect is empty when evaluated (though nonempty later)
  getScale: ->
    rect = @refs.sizeRect?.getDOMNode().getBoundingClientRect()

    return {horizontal: 1, vertical: 1} if ! rect? || ! rect.width?
    rect ?= width: 0, height: 0
    horizontal = rect.width / @props.subject.width
    vertical = rect.height / @props.subject.height
    offsetX = rect.left + $(window).scrollLeft()
    offsetY = rect.top + $(window).scrollTop()
    # PB: Adding offsetX and offsetY, which are also necessary to calculate window absolute px coordinates from source-image coordinates
    return {horizontal, vertical, offsetX, offsetY}

  getEventOffset: (e) ->
    rect = @refs.sizeRect.getDOMNode().getBoundingClientRect()
    scale = @state.scale # @getScale()
    x = ((e.pageX - window.pageXOffset - rect.left) / scale.horizontal) + @state.viewX
    y = ((e.pageY - window.pageYOffset - rect.top) / scale.vertical) + @state.viewY
    return {x, y}

  # Set mark to currently selected:
  selectMark: (mark) ->
    sel = =>
      @setState selectedMark: mark, =>
        if mark?.details?
          @forceUpdate() # Re-render to reposition the details tooltip.

    # First, if we're blurring some other uncommitted mark, commit it:
    if @state.uncommittedMark? && mark != @state.uncommittedMark
      @submitMark @state.uncommittedMark, sel

    else
      sel()


  # Destroy mark:
  destroyMark: (mark) ->
    marks = @state.marks
    ind = marks.indexOf mark

    # If it's a previously saved mark (by this or another user):
    if ind >= 0

      # Submit flag to server:
      @props.onDestroy? marks[ind]

      # Flag the subject as deleted by user:
      marks[ind].user_has_deleted = true

      @setState
        marks: marks

    else if mark is @state.uncommittedMark
      @props.destroyCurrentClassification()

  handleChange: (mark) ->
    @setState
      selectedMark: mark
        , =>
          @props.onChange? mark

  getMarksFromProps: (props) ->
    # Previous marks are really just the region hashes of all child subjects
    marks = []
    currentSubtool = props.currentSubtool
    for child_subject, i in props.subject.child_subjects
      continue if ! child_subject?
      marks[i] = child_subject.region
      marks[i].subject_id = child_subject.id # child_subject.region.subject_id = child_subject.id # copy id field into region (not ideal)
      marks[i].isTranscribable = !child_subject.user_has_classified && child_subject.status != "retired"
      marks[i].belongsToUser = child_subject.belongs_to_user
      marks[i].groupActive = currentSubtool?.generates_subject_type == child_subject.type
      marks[i].user_has_deleted = child_subject.user_has_deleted

    # Also present visible 'interim mark's for this subject:
    marks.push(m) for m in (@props.interimMarks ? []) when m.show && m.subject_id == props.subject.id

    marks

  separateTranscribableMarks: (marks) ->
    transcribableMarks = []
    otherMarks = []
    for mark in marks
      if mark.isTranscribable
        transcribableMarks.push mark
      else
        otherMarks.push mark

    return {transcribableMarks, otherMarks}

  renderMarks: (marks) ->
    return unless marks.length > 0
    # scale = @getScale()
    scale = @state.scale

    marksToRender = for mark in marks
      mark._key ?= Math.random()
      continue if ! mark.x? || ! mark.y? # if mark hasn't acquired coords yet, don't draw it yet
      continue if mark.user_has_deleted

      if @props.hideOtherMarks
        continue unless mark.belongsToUser

      displaysTranscribeButton = @props.task?.tool_config.displays_transcribe_button != false
      isPriorMark = ! mark.userCreated

      <g key={mark._key} className="marks-for-annotation#{if mark.groupActive then ' group-active' else ''}" data-disabled={isPriorMark or null}>
        {
          mark._key ?= Math.random()
          ToolComponent = markingTools[mark.toolName]
          <ToolComponent
            key={mark._key}
            subject_id={mark.subject_id}
            taskKey={@props.task?.key}
            mark={mark}
            xScale={scale.horizontal}
            yScale={scale.vertical}
            disabled={! mark.userCreated}
            disabled={! mark.userCreated}
            isTranscribable={mark.isTranscribable}
            interim={mark.interim_id?}
            isPriorMark={isPriorMark}
            subjectCurrentPage={@props.subjectCurrentPage}
            selected={mark is @state.selectedMark}
            getEventOffset={@getEventOffset}
            submitMark={@submitMark}
            sizeRect={@refs.sizeRect}
            displaysTranscribeButton={displaysTranscribeButton}

            onSelect={@selectMark.bind this, mark}
            onChange={@handleChange.bind this, mark}
            onDestroy={@destroyMark.bind this, mark}
          />
        }
      </g>

    return marksToRender

  render: ->
    return null if ! @props.active

    viewBox = @props.viewBox ? [0, 0, @props.subject.width, @props.subject.height]
    scale = @state.scale # @getScale()

    # marks = @getCurrentMarks()
    marks = @state.marks
    marks = marks.concat @state.uncommittedMark if @state.uncommittedMark?

    {transcribableMarks, otherMarks} = @separateTranscribableMarks(marks)

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

              if mark.x? && mark.y?
                ToolComponent = markingTools[toolName]
                isPriorMark = true
                <g>
                  { @highlightMark(mark, toolName) }
                  <ToolComponent
                    key={@props.subject.id}
                    xBound={@props.subject.width}
                    yBound={@props.subject.height}
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

          { @renderMarks otherMarks }
          { @renderMarks transcribableMarks }

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

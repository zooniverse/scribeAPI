# @cjsx React.DOM
React           = require 'react'
Draggable       = require 'lib/draggable'
DoneButton      = require './done-button'
inputComponents = require '../../input-components'

TextTool = React.createClass
  displayName: 'SingleTool'

  getInitialState: ->
    viewerSize: @props.viewerSize
    annotation:
      value: ''

  getDefaultProps: ->
    annotation: {}
    task: null
    subject: null
    clickOffsetX: 0
    clickOffsetY: 0

  componentWillReceiveProps: ->
    @setState
      annotation: @props.annotation

  componentDidMount: -> # not sure if this does anything? --STI
    @updatePosition()

  handleInitStart: (e,d) ->
    # prevent dragging from non-divs (a bit hacky) --STI
    @setState preventDrag: e.target.nodeName isnt 'DIV'

    @props.clickOffsetX = e.nativeEvent.offsetX + e.nativeEvent.srcElement.offsetParent.offsetLeft
    @props.clickOffsetY = e.nativeEvent.offsetY + e.nativeEvent.srcElement.offsetParent.offsetTop

  handleInitDrag: (e, d) ->
    return if @state.preventDrag # not too happy about this one

    dx = e.clientX - @props.clickOffsetX + window.scrollX
    dy = e.clientY - @props.clickOffsetY + window.scrollY

    @setState dragged: true, dx: dx, dy: dy

  # Expects size hash with:
  #   w: [viewer width]
  #   h: [viewer height]
  #   scale:
  #     horizontal: [horiz scaling of image to fit within above vals]
  #     vertical:   [vert scaling of image..]
  onViewerResize: (size) ->
    @setState
      viewerSize: size
    @updatePosition()

  updatePosition: ->

    # HANDLE DIFFERENT TOOLS
    toolName = @props.subject.data.toolName
    switch toolName
      when 'pointTool'
        x = @props.subject.data.x + 40
        y = @props.subject.data.y + 40 # TODO: don't hard-wire dimensions
      when 'rectangleTool'
        x = @props.subject.data.x
        y = @props.subject.data.y + @props.subject.data.height
      when 'textRowTool'
        x = if @state.viewerSize? then (@state.viewerSize.w-650 )/2 else 0 # TODO: don't hard-wire dimensions
        y = @props.subject.data.yLower
      else
        console.log "ERROR: Cannot update position on unknown transcription tool #{toolName}!"

    if @state.viewerSize? && ! @state.dragged
      @setState
        dx: x * @state.viewerSize.scale.horizontal
        dy: y * @state.viewerSize.scale.vertical

  commitAnnotation: ->
    @props.onComplete @state.annotation

  handleChange: (e) ->
    @state.annotation.value = e.target.value
    @forceUpdate()

  handleKeyPress: (e) ->
    if [13].indexOf(e.keyCode) >= 0 # ENTER:
      @commitAnnotation()
      e.preventDefault()

  render: ->
    return null unless @props.viewerSize? && @props.subject?

    # If user has set a custom position, position based on that:
    style =
      left: @state.dx
      top: @state.dy

    val = @state.annotation?.value ? ''


    if @props.subject.type is 'item_location'
      toolType = 'testComponent'
    else
      toolType = @props.task.tool_options.tool_type

    unless inputComponents[toolType]?
      console.log "ERROR: Field type, #{toolType}, does not exist!"
      return null

    InputComponent = inputComponents[toolType]

    <Draggable
      onStart = {@handleInitStart}
      onDrag  = {@handleInitDrag}
      onEnd   = {@handleInitRelease}
      ref     = "inputWrapper0">
      <div className="transcribe-tool" style={style}>
        <InputComponent
          key={@props.task.key}
          val={@state.annotation?.value ? ''}
          instruction={@props.task.instruction}
          handleChange={@handleChange}
          onKeyPress={@handleKeyPress}
          commitAnnotation={@commitAnnotation}
        />
      </div>
    </Draggable>

module.exports = TextTool

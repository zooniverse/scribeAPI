# @cjsx React.DOM
React           = require 'react'
Draggable       = require '../../../../lib/draggable'
DoneButton      = require './done-button'

TextTool = React.createClass
  displayName: 'DateTool'

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

  componentDidMount: ->
    console.log 'componentDidMount()'
    # @updatePosition()

  handleInitStart: (e,d) ->
    # prevent dragging from non-divs (a bit hacky) --STI
    @setState preventDrag: e.target.nodeName isnt 'DIV'

    @props.clickOffsetX = e.nativeEvent.offsetX + e.nativeEvent.srcElement.offsetParent.offsetLeft  #$('.transcribe-tool').offsetX# - e.offsetX #().left
    @props.clickOffsetY = e.nativeEvent.offsetY + e.nativeEvent.srcElement.offsetParent.offsetTop #$('.transcribe-tool').offsetY# - e.offsetY #().top

  handleInitDrag: (e, delta) ->
    console.log 'handleInitDrag()'
    return if @state.preventDrag # not too happy about this one

    dx = e.clientX - @props.clickOffsetX + window.scrollX
    dy = e.clientY - @props.clickOffsetY + window.scrollY

    @setState
      dx: dx
      dy: dy
      dragged: true
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
    if @state.viewerSize? && ! @state.dragged
      @setState
        dx: @props.subject.data.x * @state.viewerSize.scale.horizontal
        dy: (@props.subject.data.y + @props.subject.data.height) * @state.viewerSize.scale.vertical
      # console.log "TextTool#updatePosition setting state: ", @state

  commitAnnotation: ->
    @props.onComplete @state.annotation

  handleChange: (e) ->
    @state.annotation.value = e.target.value
    @forceUpdate()

  render: ->
    return null unless @props.viewerSize? && @props.subject?

    # If user has set a custom position, position based on that:
    style =
      left: @state.dx
      top: @state.dy
    # console.log "TextTool#render pos", @state

    val = @state.annotation?.value ? ''
    # console.log "TextTool#render val:", val, @state.annotation?.value

    <Draggable
      onStart = {@handleInitStart}
      onDrag  = {@handleInitDrag}
      onEnd   = {@handleInitRelease}
      ref     = "inputWrapper0">

      <div className="transcribe-tool" style={style}>
        <div className="left">
          <div className="input-field active">
            <label>{@props.task.instruction}</label>
            <input ref="input0" type="date" data-task_key={@props.task.key} onChange={@handleChange} value={val} />
          </div>
        </div>
        <div className="right">
          <DoneButton onClick={@commitAnnotation} />
        </div>
      </div>
    </Draggable>

module.exports = TextTool

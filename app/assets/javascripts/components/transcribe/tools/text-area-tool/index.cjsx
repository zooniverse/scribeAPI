# @cjsx React.DOM
React           = require 'react'
Draggable       = require '../../../../lib/draggable'
DoneButton      = require './done-button'

TextTool = React.createClass
  displayName: 'TextAreaTool'

  handleInitStart: (e) ->
    # console.log 'handleInitStart() '
    @setState preventDrag: false
    if e.target.nodeName is "INPUT" or e.target.nodeName is "TEXTAREA"
      @setState preventDrag: true

    @setState
      xClick: e.pageX - $('.transcribe-tool').offset().left
      yClick: e.pageY - $('.transcribe-tool').offset().top

  handleInitDrag: (e, delta) ->

    return if @state.preventDrag # not too happy about this one

    dx = e.pageX - @state.xClick - window.scrollX
    dy = e.pageY - @state.yClick # + window.scrollY

    @setState
      dx: dx
      dy: dy #, =>
      dragged: true

  getInitialState: ->
    viewerSize: @props.viewerSize
    annotation:
      value: ''

  getDefaultProps: ->
    annotation: {}
    task: null
    subject: null

  componentWillReceiveProps: ->
    @setState
      annotation: @props.annotation

  componentDidMount: ->
    @updatePosition()

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
        dx: @props.subject.location.data.x * @state.viewerSize.scale.horizontal
        dy: (@props.subject.location.data.y + @props.subject.location.data.height) * @state.viewerSize.scale.vertical
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
            <textarea ref="input0" data-task_key={@props.task.key} onChange={@handleChange} value={val} placeholder={"This is some placeholder text."} />
          </div>
        </div>
        <div className="right">
          <DoneButton onClick={@commitAnnotation} />
        </div>
      </div>
    </Draggable>

module.exports = TextTool

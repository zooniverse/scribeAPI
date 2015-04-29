# @cjsx React.DOM
React           = require 'react'
Draggable       = require '../../../../lib/draggable'
DoneButton      = require './done-button'

TextTool = React.createClass
  displayName: 'TextTool'

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
    viewerScale: null
    annotation:
      value: ''

  getDefaultProps: ->
    annotation: {}
    task: null
    subject: null
   
  componentWillReceiveProps: ->
    @setState
      annotation: @props.annotation
    # console.log "TextTool:componentWillReceiveProps", @props#.input0.value = ''

  componentDidMount: ->
    # console.log "TextTool:componentDidMount refs.input0?", @refs.input0?
    if @refs.input0?
      @refs.input0.value = 'changed..'
      # console.log "TextTool:componentDidMount refs.input0 = ..", @refs.input0

  onViewerResize: (size) ->
    return null if @state.dragged

    scale = size.scale.horizontal

    dx = @props.subject.location.x * scale
    dy = ( @props.subject.location.y + @props.subject.location.h ) * scale

    @setState
      viewerScale: scale # cause horiz should = vert...
      dx: dx
      dy: dy

  commitAnnotation: ->
    @props.onComplete @state.annotation

  handleChange: (e) ->
    @state.annotation.value = e.target.value
    # console.log "setting ann val: ", @state.annotation
    @forceUpdate()

  render: ->
    return null unless @props.viewerSize? && @props.subject?

    # If user has set a custom position, position based on that:
    if @state.dragged
      style =
        left: @state.dx
        top: @state.dy

    # Otherwise compute position based on location of secondary subject:
    else
      style =
        left: "#{@props.subject.location.x / @props.viewerSize.w * 100}%"
        top: "#{@props.subject.location.y / @props.viewerSize.h * 100}%"

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
            <input ref="input0" type="text" data-task_key={@props.task.key} onChange={@handleChange} value={val} />
          </div>
        </div>
        <div className="right">
          <DoneButton onClick={@commitAnnotation} />
        </div>
      </div>
    </Draggable>

module.exports = TextTool

# @cjsx React.DOM
React      = require 'react'
Draggable  = require '../../../../lib/draggable'
DoneButton = require './done-button'
PrevButton = require './prev-button'

TextTool = React.createClass
  displayName: 'TextTool'

  handleInitStart: (e) ->
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
    # compute component location
    {x,y} = @getPosition @props.subject.data

    dx: x
    dy: y
    viewerSize: @props.viewerSize
    annotation:
      value: ''

  getPosition: (data) ->
    switch data.toolName
      when 'rectangleTool'
        x = data.x
        y = parseFloat(data.y) + parseFloat(data.height)
      when 'textRowTool'
        x = data.x
        y = data.yLower
      else # default for pointTool
        x = data.x
        y = data.y
    return {x,y}

  getDefaultProps: ->
    annotation: {}
    task: null
    subject: null
    standalone: true
    annotation_key: 'value'
    focus: true

  componentWillReceiveProps: ->
    @refs.input0.getDOMNode().focus() if @props.focus
    {x,y} = @getPosition @props.subject.data
    @setState
      dx: x
      dy: y
      annotation: @props.annotation
      , => @forceUpdate() # updates component position on new subject

  componentWillMount: ->
    # currently does nothing

  componentWillUnmount: ->
    if @props.task.tool_config.suggest == 'common'
      el = $(@refs.input0.getDOMNode())
      el.autocomplete 'destroy'

  componentDidMount: ->
    @updatePosition()
    @refs.input0.getDOMNode().focus() if @props.focus

    if @props.task.tool_config.suggest == 'common'
      el = $(@refs.input0.getDOMNode())
      el.autocomplete
        source: (request, response) =>
          $.ajax
            url: "/classifications/terms/#{@props.workflow.id}/#{@props.key}"
            dataType: "json"
            data:
              q: request.term
            success: ( data ) =>
              response( data )
        minLength: 3

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

  commitAnnotation: ->
    @props.onComplete @state.annotation

  handleChange: (e) ->
    @state.annotation[@props.annotation_key] = e.target.value
    @forceUpdate()

  handleKeyPress: (e) ->
    if [13].indexOf(e.keyCode) >= 0 # ENTER
      @commitAnnotation()
      e.preventDefault()

  render: ->

    # get component position
    style =
      left: "#{@state.dx*@props.scale.horizontal}px"
      top: "#{@state.dy*@props.scale.vertical}px"

    val = @state.annotation[@props.annotation_key] ? ''

    unless @props.standalone
      label = @props.label ? ''
    else
      label = @props.task.instruction

    # create component input field(s)
    tool_content =
      <div className="input-field active">
        <label>{label}</label>
        <input ref="input0" type="text" data-task_key={@props.task.key} onKeyDown={@handleKeyPress} onChange={@handleChange} value={val} />
      </div>

    if @props.standalone # 'standalone' true if component handles own mouse events
      tool_content =
        <Draggable
          onStart={@handleInitStart}
          onDrag={@handleInitDrag}
          onEnd={@handleInitRelease}
          ref="inputWrapper0"
          x={@state.dx*@props.scale.horizontal}
          y={@state.dy*@props.scale.vertical}>

          <div className="transcribe-tool" style={style}>
            <div className="left">
              {tool_content}
            </div>
            <div className="right">
              <PrevButton onClick={null} />
              <DoneButton onClick={@commitAnnotation} />
            </div>
          </div>

        </Draggable>
    else return tool_content # render input fields without Draggable

module.exports = TextTool

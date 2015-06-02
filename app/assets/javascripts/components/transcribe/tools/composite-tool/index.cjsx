# @cjsx React.DOM
React           = require 'react'
Draggable       = require '../../../../lib/draggable'
DoneButton      = require './done-button'

text_tool = require '../text-tool'
tools = require '../'

CompositeTool = React.createClass
  displayName: 'CompositeTool'

  getInitialState: ->
    active_field_key: null

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
    annotation: {}

  componentWillReceiveProps: ->
    @setState
      annotation: @props.annotation
      active_field_key: (key for key, v of @props.task.tool_config.tools)[0]

  componentDidMount: ->
    @updatePosition()
    @setState
      active_field_key: (key for key, v of @props.task.tool_config.tools)[0]

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
        dx: @props.subject.location.spec.x * @state.viewerSize.scale.horizontal
        dy: (@props.subject.location.spec.y + @props.subject.location.spec.height) * @state.viewerSize.scale.vertical
      # console.log "TextTool#updatePosition setting state: ", @state

  handleFieldComplete: (key, ann) ->
    inp = @refs[key]

    keys = (key for key, t in @props.task.tool_config.tools)
    next_key = keys[keys.indexOf(@state.active_field_key) + 1]
    if next_key?
      @setState active_field_key: next_key, () =>
        @forceUpdate()
    else
      @setState annotation: ann, () =>
        @commitAnnotation()

  commitAnnotation: ->
    @props.onComplete @state.annotation

  render: ->
    style =
      left: @state.dx
      top: @state.dy

    # console.log "CompositeTool#render: ", @props, @props.task, text_tool, tools, @props.transcribe_tools
    <Draggable
      onStart = {@handleInitStart}
      onDrag  = {@handleInitDrag}
      onEnd   = {@handleInitRelease}
      ref     = "inputWrapper0">

      <div className="transcribe-tool composite" style={style}>
        <div className="left">
          <div className="input-field active">
            <label>{@props.task.instruction}</label>
            { for annotation_key, tool_config of @props.task.tool_config.tools
              # path = "../#{tool_config.tool.replace(/_/, '-')}"
              tool_inst = @props.transcribe_tools[tool_config.tool]
              focus = annotation_key == @state.active_field_key

              tool_props =
                task: @props.task
                subject: @props.subject
                workflow: @props.workflow
                label: @props.task.tool_config.tools[annotation_key].label ? ''
                annotation_key: annotation_key
                standalone: false
                onComplete: @handleFieldComplete.bind(@, annotation_key)
                focus: focus
              # onComplete={@handleTaskComplete} onBack={@makeBackHandler()}
              <tool_inst {...tool_props} key={annotation_key} ref={annotation_key} annotation={@props.annotation[annotation_key]} />
            }
          </div>
        </div>
        <div className="right">
          <DoneButton onClick={@commitAnnotation} />
        </div>
      </div>
    </Draggable>

module.exports = CompositeTool

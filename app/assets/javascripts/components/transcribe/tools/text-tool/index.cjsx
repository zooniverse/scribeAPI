# @cjsx React.DOM
React      = require 'react'
Draggable  = require 'lib/draggable'
DoneButton = require './done-button'
PrevButton = require './prev-button'
{Navigation} = require 'react-router'

TextTool = React.createClass
  displayName: 'TextTool'

  mixins: [Navigation]

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

  # this can go into a mixin? (common across all transcribe tools)
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
    key: 'value'
    focus: true

  componentWillReceiveProps: ->
    console.log 'PROPS: ', @props
    @refs[@props.ref || 'input0'].getDOMNode().focus() if @props.focus

    {x,y} = @getPosition @props.subject.data
    @setState
      dx: x
      dy: y, => @forceUpdate() # updates component position on new subject

  componentWillUnmount: ->
    if @props.task.tool_config.suggest == 'common'
      el = $(@refs.input0.getDOMNode())
      el.autocomplete 'destroy'

  componentDidMount: ->
    @updatePosition()

    if @props.task.tool_config.suggest == 'common'
      el = $(@refs.input0.getDOMNode())
      el.autocomplete
        source: (request, response) =>
          field = "#{@props.task.key}:#{@fieldKey()}"
          $.ajax
            url: "/classifications/terms/#{@props.workflow.id}/#{field}"
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

  # this can go into a mixin? (common across all transcribe tools)
  # NOTE: doesn't get called unless @props.standalone is true
  commitAnnotation: ->
    @props.onComplete @props.annotation

  # this can go into a mixin? (common across all transcribe tools)
  returnToMarking: ->
    @commitAnnotation()

    # transition back to mark
    @replaceWith 'mark', {},
      subject_set_id: @props.subject.subject_set_id
      selected_subject_id: @props.subject.parent_subject_id.$oid
      page: @props.subjectCurrentPage

  # Get key to use in annotations hash (i.e. typically 'value', unless included in composite tool)
  fieldKey: ->
    if @props.standalone
      'value'
    else
      @props.annotation_key

  handleChange: (e) ->
    newAnnotation = []
    newAnnotation[@fieldKey()] = e.target.value

    # if composite-tool is used, this will be a callback to CompositeTool::handleChange()
    # otherwise, it'll be a callback to Transcribe::handleDataFromTool()
    @props.onChange(newAnnotation) # report updated annotation to parent

  handleKeyPress: (e) ->
    if [13].indexOf(e.keyCode) >= 0 # ENTER
      @commitAnnotation()
      e.preventDefault()

  render: ->
    style =
      left: "#{@state.dx*@props.scale.horizontal}px"
      top: "#{@state.dy*@props.scale.vertical}px"

    val = @props.annotation[@fieldKey()]
    val = '' if ! val?

    unless @props.standalone
      label = @props.label ? ''
    else
      label = @props.task.instruction

    ref = @props.ref || "input0"

    # create component input field(s)
    tool_content =
      <div className="input-field active">
        <label>{label}</label>
        {
          atts =
            ref: ref
            "data-task_key": @props.task.key
            onKeyDown: @handleKeyPress
            onChange: @handleChange
            value: val

          if @props.textarea
            <textarea key={@props.task.key} value={val} {...atts} />

          else
            <input type="text" value={val} {...atts} />
        }
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
              { # THIS CAN PROBABLY BE REFACTORED --STI
                if window.location.hash is '#/transcribe' # regular transcribe, i.e. no mark transition
                  <DoneButton onClick={@commitAnnotation} />
                else
                  if @props.task.next_task?
                    <span>
                      <button className='button done' onClick={@commitAnnotation}>
                        {'Next'}
                      </button>
                    </span>
                  else
                    <span>
                      <label>Return to marking: </label>
                      <button className='button done' onClick={@returnToMarking}>
                        {'Finish'}
                      </button>
                    </span>
              }
            </div>
          </div>

        </Draggable>
    else return tool_content # render input fields without Draggable

module.exports = TextTool

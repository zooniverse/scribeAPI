React           = require 'react'
{Navigation}    = require 'react-router'
DraggableModal  = require 'components/draggable-modal'
DoneButton      = require './done-button'
PrevButton      = require './prev-button'

TextTool = React.createClass
  displayName: 'TextTool'

  mixins: [Navigation]

  getInitialState: ->
    annotation: @props.annotation ? {}
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
    annotation_key: null
    task: null
    subject: null
    standalone: true
    focus: true
    inputType: 'text'

  componentWillUnmount: ->
    tool_config = @toolConfig()
    if tool_config.suggest == 'common'
      el = $(@refs.input0.getDOMNode())
      el.autocomplete 'destroy' if el.autocomplete?

  toolConfig: ->
    @props.tool_config ? @props.task.tool_config

  # Set focus on input:
  focus: ->
    el = $(@refs.input0?.getDOMNode())
    if el? && el.length
      el.focus()

  componentWillReceiveProps: (new_props) ->
    # PB: Note this func is defined principally to allow a parent composite-tool
    # to set focus on a child tool via props but this consistently fails to
    # actually set focus - probably because the el.focus() call is made right
    # before an onkeyup event or something, which quietly reverses it.
    if new_props.focus
      @focus()

    @applyAutoComplete()

  componentDidMount: ->

    @applyAutoComplete()

    @focus() if @props.focus

  applyAutoComplete: ->
    if @isMounted() && @toolConfig().suggest == 'common'
      el = $(@refs.input0?.getDOMNode())
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

  # this can go into a mixin? (common across all transcribe tools)
  # NOTE: doesn't get called unless @props.standalone is true
  commitAnnotation: ->
    ann = @state.annotation
    @props.onComplete ann

  # this can go into a mixin? (common across all transcribe tools)
  returnToMarking: ->
    console.log 'returnToMarking()'
    @commitAnnotation()

    # transition back to mark
    @transitionTo 'mark', {},
      subject_set_id: @props.subject.subject_set_id
      selected_subject_id: @props.subject.parent_subject_id
      page: @props.subjectCurrentPage

  # Get key to use in annotations hash (i.e. typically 'value', unless included in composite tool)
  fieldKey: ->
    if @props.standalone
      'value'
    else
      @props.annotation_key

  handleChange: (e) ->
    newAnnotation = @state.annotation
    newAnnotation[@fieldKey()] = e.target.value

    # if composite-tool is used, this will be a callback to CompositeTool::handleChange()
    # otherwise, it'll be a callback to Transcribe::handleDataFromTool()
    @props.onChange(newAnnotation) # report updated annotation to parent

  handleKeyPress: (e) ->
    if [13].indexOf(e.keyCode) >= 0 # ENTER
      @commitAnnotation()
      e.preventDefault()

  handleBadMark: ()->
    newAnnotation = []
    newAnnotation["low_quality_subject"]

  render: ->
    return null if @props.loading # hide transcribe tool while loading image

    val = @state.annotation[@fieldKey()]

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
            key: "#{@props.task.key}.#{@props.annotation_key}"
            "data-task_key": @props.task.key
            onKeyDown: @handleKeyPress
            onChange: @handleChange
            onFocus: ( () => @props.onInputFocus? @props.annotation_key )
            value: val

          if @props.inputType == "text"
            <input type="text" value={val} {...atts} />

          else if @props.inputType == "textarea"
            <textarea key={@props.task.key} value={val} {...atts} />

          else if @props.inputType == "number"
            # Let's not make it input[type=number] because we don't want the browser to absolutely *force* numeric; We should coerce numerics without obliging
            <input type="text" value={val} {...atts} />

          else if @props.inputType == "date"
            <input type="date" value={val} {...atts} />

          else console.warn "Invalid inputType specified: #{@props.inputType}"

        }
      </div>

    if @props.standalone # 'standalone' true if component handles own mouse events

      buttons = []

      if @props.onShowHelp?
        buttons.push(<button key="help-button" type="button" className="pill-button help-button" onClick={@props.onShowHelp}>
          Need some help?
        </button>)

      if window.location.hash is '#/transcribe' || @props.task.next_task? # regular transcribe, i.e. no mark transition
        buttons.push <DoneButton label={if @props.task.next_task? then 'Next' else 'Done'} key="done-button" onClick={@commitAnnotation} />
      else
        buttons.push <DoneButton label='Finish' key="done-button" onClick={@returnToMarking} />

      {x,y} = @getPosition @props.subject.region

      tool_content = <DraggableModal
        x={x*@props.scale.horizontal}
        y={y*@props.scale.vertical}
        buttons={buttons}
        classes="transcribe-tool"
        >

          {tool_content}

      </DraggableModal>

    <div>
      {tool_content}
    </div>

module.exports = TextTool

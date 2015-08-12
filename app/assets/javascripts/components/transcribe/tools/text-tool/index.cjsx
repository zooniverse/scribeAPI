React                  = require 'react'
{Navigation}           = require 'react-router'
DraggableModal         = require 'components/draggable-modal'
SmallButton            = require 'components/buttons/small-button'
HelpButton             = require 'components/buttons/help-button'
BadSubjectButton       = require 'components/buttons/bad-subject-button'
IllegibleSubjectButton = require 'components/buttons/illegible-subject-button'


TextTool = React.createClass
  displayName: 'TextTool'
  mixins: [Navigation]

  getInitialState: ->
    annotation: @props.annotation ? {}
    viewerSize: @props.viewerSize
    autocompleting: false

  # this can go into a mixin? (common across all transcribe tools)
  getPosition: (data) ->
    yPad = 20
    switch data.toolName
      when 'rectangleTool'
        x = data.x
        y = parseFloat(data.y) + parseFloat(data.height) + yPad
      when 'textRowTool'
        x = data.x
        y = data.yLower + yPad
      else # default for pointTool
        x = data.x
        y = data.y + yPad
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

    # Required to ensure tool has cleared annotation even if tool doesn't unmount between tasks:
    @setState
      annotation: new_props.annotation ? {}
      viewerSize: new_props.viewerSize

  shouldComponentUpdate: ->
    console.log "should update? ", @props, @state
    true

  componentDidMount: ->
    @applyAutoComplete()
    @focus() if @props.focus

  componentDidUpdate: ->
    @applyAutoComplete()
    @focus() if @props.focus

  applyAutoComplete: ->
    if @isMounted() && @toolConfig().suggest == 'common'
      el = $(@refs.input0?.getDOMNode())
      el.autocomplete
        open: ( => @setState autocompleting: true )
        close: => setTimeout( (=> @setState(autocompleting: false)), 1000)
        select: (e, ui) => @updateValue(ui.item.value)
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

  getCaret: ()->
    el = $(@refs.input0?.getDOMNode())


  updateValue: (val) ->
    console.log "updated val: ", val
    newAnnotation = @state.annotation
    newAnnotation[@fieldKey()] = val

    # if composite-tool is used, this will be a callback to CompositeTool::handleChange()
    # otherwise, it'll be a callback to Transcribe::handleDataFromTool()
    @props.onChange(newAnnotation) # report updated annotation to parent

  handleChange: (e) ->
    @updateValue e.target.value

  handleKeyDown: (e) ->
    @handleChange(e) # updates any autocomplete values
    # if [13].indexOf(e.keyCode) >= 0 # ENTER

    if (! @state.autocompleting && [13].indexOf(e.keyCode) >= 0) && !e.shiftKey# ENTER
      if window.location.hash is '#/transcribe' || @props.task.next_task? # regular transcribe, i.e. no mark transition
        @commitAnnotation()
      else
        @returnToMarking()
    else if e.keyCode == 13 && e.shiftKey
      text_area =  $("textarea")
      the_text = text_area.val()
      the_text = the_text.concat("/n")
      text_area.val(the_text)

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
            onKeyDown: @handleKeyDown
            onChange: @handleChange
            onFocus: ( () => @props.onInputFocus? @props.annotation_key )
            value: val
            disabled: @props.badSubject

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
        buttons.push <HelpButton onClick={@props.onShowHelp}/>

      if @props.onBadSubject?
        buttons.push <BadSubjectButton active={@props.badSubject} onClick={@props.onBadSubject} />

      if @props.onIllegibleSubject?
        buttons.push <IllegibleSubjectButton active={@props.illegibleSubject} onClick={@props.onIllegibleSubject} />

      if window.location.hash is '#/transcribe' || @props.task.next_task? # regular transcribe, i.e. no mark transition
        buttons.push <SmallButton label={if @props.task.next_task? then 'Next' else 'Done'} key="done-button" onClick={@commitAnnotation} />
      else
        buttons.push <SmallButton label='Finish' key="done-button" onClick={@returnToMarking} />

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

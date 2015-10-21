React             = require 'react'
{Navigation}      = require 'react-router'
DraggableModal    = require 'components/draggable-modal'
DoneButton        = require './done-button'
SmallButton       = require 'components/buttons/small-button'
PrevButton        = require './prev-button'
HelpButton        = require 'components/buttons/help-button'
BadSubjectButton  = require 'components/buttons/bad-subject-button'
IllegibleSubjectButton = require 'components/buttons/illegible-subject-button'


CompositeTool = React.createClass
  displayName: 'CompositeTool'
  mixins: [Navigation]

  getInitialState: ->
    annotation: @props.annotation ? {}
    viewerSize: @props.viewerSize
    active_field_key: (c.value for c in @props.task.tool_config.options)[0]

  getDefaultProps: ->
    annotation: {}
    task: null
    subject: null

  # this can go into a mixin? (common across all transcribe tools)
  getPosition: (data) ->
    return x: null, y: null if ! data.x?

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
        y = data.y + yPad if data.y?
    x = @props.subject.width / 2 if ! x?
    y = @props.subject.height / 2 if ! y?
    return {x,y}

  onViewerResize: (size) ->
    @setState
      viewerSize: size

  handleChange: (annotation) ->
    @setState annotation: annotation

    @props.onChange annotation # forward annotation to parent

  # Fires when user hits <enter> in an input
  # If there are more inputs, move focus to next input
  # Otherwise commit annotation (which is default behavior when there's only one input
  handleCompletedField: ->
    field_keys = (c.value for c of @props.task.tool_config.options)
    next_field_key = field_keys[ field_keys.indexOf(@state.active_field_key) + 1 ]

    if next_field_key?
      @setState active_field_key: next_field_key
        , =>
          @forceUpdate()
    else
      @commitAnnotation()

  # User moved focus to an input:
  handleFieldFocus: (annotation_key) ->
    @setState active_field_key: annotation_key

  # this can go into a mixin? (common across all transcribe tools)
  commitAnnotation: ->
    # Clear current annotation so that it doesn't carry over into next task if next task uses same tool
    ann = @state.annotation
    @setState annotation: {}, () =>
      @props.onComplete ann

    if @props.transcribeMode is 'page' or @props.transcribeMode is 'single'
      if @props.isLastSubject and not @props.task.next_task?
        @props.returnToMarking()

  # this can go into a mixin? (common across all transcribe tools)
  returnToMarking: ->
    @commitAnnotation()

    # transition back to mark
    @transitionTo 'mark', {},
      subject_set_id: @props.subject.subject_set_id
      selected_subject_id: @props.subject.parent_subject_id
      page: @props.subjectCurrentPage

  render: ->
    buttons = []
    # TK: buttons.push <PrevButton onClick={=> console.log "Prev button clicked!"} />

    if @props.onShowHelp?
      buttons.push <HelpButton onClick={@props.onShowHelp}/>

    if @props.onBadSubject?
      buttons.push <BadSubjectButton active={@props.badSubject} onClick={@props.onBadSubject} />

    if @props.onIllegibleSubject?
      buttons.push <IllegibleSubjectButton active={@props.illegibleSubject} onClick={@props.onIllegibleSubject} />

    buttonLabel =
      if @props.task.next_task?
       'Continue'
      else
        if @props.isLastSubject and ( @props.transcribeMode is 'page' or @props.transcribeMode is 'single' )
          'Return to Marking'
        else 'Next Entry'

    buttons.push <SmallButton label={buttonLabel} key="done-button" onClick={@commitAnnotation} />

    {x,y} = @getPosition @props.subject.region

    <DraggableModal
      x={x*@props.scale.horizontal + @props.scale.offsetX}
      y={y*@props.scale.vertical + @props.scale.offsetY}
      buttons={buttons}
      classes="transcribe-tool composite"
      >

      <label>{@props.task.instruction}</label>

      {
        for sub_tool, index in @props.task.tool_config.options
          ToolComponent = @props.transcribeTools[sub_tool.tool]
          annotation_key = sub_tool.value
          focus = annotation_key is @state.active_field_key

          <ToolComponent
            key={index}
            task={@props.task}
            tool_config={sub_tool.tool_config}
            subject={@props.subject}
            workflow={@props.workflow}
            standalone={false}
            viewerSize={@props.viewerSize}
            onChange={@handleChange}
            onComplete={@handleCompletedField}
            onInputFocus={@handleFieldFocus}
            label={sub_tool.label ? ''}
            focus={focus}
            scale={@props.scale}
            annotation_key={annotation_key}
            annotation={@state.annotation}
          />
      }

    </DraggableModal>

module.exports = CompositeTool

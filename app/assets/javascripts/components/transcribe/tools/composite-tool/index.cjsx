React             = require 'react'
{Navigation}      = require 'react-router'
DraggableModal    = require 'components/draggable-modal'
DoneButton        = require './done-button'
PrevButton        = require './prev-button'
HelpButton        = require 'components/buttons/help-button'
BadSubjectButton  = require 'components/buttons/bad-subject-button'

CompositeTool = React.createClass
  displayName: 'CompositeTool'
  mixins: [Navigation]

  getInitialState: ->
    annotation: @props.annotation ? {}
    viewerSize: @props.viewerSize
    active_field_key: (key for key, value of @props.task.tool_config.tools)[0]

  getDefaultProps: ->
    annotation: {}
    task: null
    subject: null

  # componentWillReceiveProps: (new_props) ->
  #   @setState annotation: new_props

  # this can go into a mixin? (common across all transcribe tools)
  # DUPE in text-tool:
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
    field_keys = (annotation_key for annotation_key, tool_config of @props.task.tool_config.tools)
    next_field_key = field_keys[ field_keys.indexOf(@state.active_field_key) + 1 ]

    if next_field_key?
      @setState active_field_key: next_field_key

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

  # this can go into a mixin? (common across all transcribe tools)
  returnToMarking: ->
    console.log 'returnToMarking()'
    @commitAnnotation()

    # transition back to mark
    @transitionTo 'mark', {},
      subject_set_id: @props.subject.subject_set_id
      selected_subject_id: @props.subject.parent_subject_id
      page: @props.subjectCurrentPage

  render: ->
    buttons = []
    # TK: buttons.push <PrevButton onClick={=> console.log "Prev button clicked!"} />

    if window.location.hash is '#/transcribe' || @props.task.next_task? # regular transcribe, i.e. no mark transition
      buttons.push <DoneButton label={if @props.task.next_task? then 'Next' else 'Done'} key="done-button" onClick={@commitAnnotation} />
    else
      buttons.push <DoneButton label='Finish' key="done-button" onClick={@returnToMarking} />

    if @props.onShowHelp?
      buttons.push <HelpButton onClick={@props.onShowHelp}/>

    if @props.onBadSubject?
      buttons.push <BadSubjectButton active={@props.badSubject} onClick={@props.onBadSubject} />

    {x,y} = @getPosition @props.subject.region

    <DraggableModal
      x={x*@props.scale.horizontal}
      y={y*@props.scale.vertical}
      buttons={buttons}
      classes="transcribe-tool composite"
      >

      <label>{@props.task.instruction}</label>
      {
        for annotation_key, tool_config of @props.task.tool_config.tools
          ToolComponent = @props.transcribeTools[tool_config.tool]
          focus = annotation_key is @state.active_field_key

          <ToolComponent
            task={@props.task}
            tool_config={@props.task.tool_config.tools[annotation_key].tool_config}
            subject={@props.subject}
            workflow={@props.workflow}
            standalone={false}
            viewerSize={@props.viewerSize}
            onChange={@handleChange}
            onComplete={@handleCompletedField}
            onInputFocus={@handleFieldFocus}
            label={@props.task.tool_config.tools[annotation_key].label ? ''}
            focus={focus}
            scale={@props.scale}
            annotation_key={annotation_key}
            annotation={@state.annotation}
          />
      }

    </DraggableModal>

module.exports = CompositeTool

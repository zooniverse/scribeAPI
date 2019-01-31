React                   = require 'react'
DraggableModal          = require '../../../draggable-modal'
GenericButton           = require 'components/buttons/generic-button'
DoneButton              = require 'components/buttons/done-button'
HelpButton              = require 'components/buttons/help-button'
BadSubjectButton        = require 'components/buttons/bad-subject-button'
SmallButton             = require 'components/buttons/small-button'

VerifyTool = React.createClass
  displayName: 'VerifyTool'

  getInitialState: ->
    annotation:
      value: ''

  getDefaultProps: ->
    annotation: {}
    task: null
    subject: null
    standalone: true
    annotation_key: 'value'
    focus: true
    doneButtonLabel: 'Okay'
    transcribeButtonLabel: 'None of these? Enter your own'

  componentWillReceiveProps: ->
    @setState
      annotation: @props.annotation

  commitAnnotation: ->
    @props.onComplete @state.annotation

  handleChange: (e) ->
    @state.annotation[@props.annotation_key] = e.target.value
    @forceUpdate()

  handleKeyPress: (e) ->

    if [13].indexOf(e.keyCode) >= 0 # ENTER:
      @commitAnnotation()
      e.preventDefault()

  chooseOption: (e) ->
    el = $(e.target)
    el = $(el.parents('a')[0]) if el.tagName != 'A'
    value = @props.subject.data['values'][el.data('value_index')]

    @setState({annotation: value}, () =>
      @commitAnnotation()
    )

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

  editAnnotation: (ann) ->
    url = "/#/transcribe/#{@props.subject.parent_subject_id}?scrollX=#{window.scrollX}&scrollY=#{window.scrollY}&from=verify"
    url += "&" + ("annotation[#{k}]=#{v}" for k,v of ann).join('&')
    window.location.href = url

  render: ->
    # return null unless @props.viewerSize? && @props.subject?
    # return null if ! @props.scale? || ! @props.scale.horizontal?
    return null if @props.loading # hide verify tool while loading image

    val = @state.annotation[@props.annotation_key] ? ''

    label = @props.task.instruction
    if ! @props.standalone
      label = @props.label ? ''

    buttons = []

    if @props.onShowHelp?
      buttons.push <HelpButton onClick={@props.onShowHelp} key="help-button"/>

    if @props.task?.tool_config.displays_transcribe_button? and @props.subject?
      transcribe_url = "/#/transcribe/#{@props.subject.parent_subject_id}?scrollX=#{window.scrollX}&scrollY=#{window.scrollY}&page=#{@props.subject._meta?.current_page}"
      buttons.push <GenericButton key="transcribe-button" label={@props.transcribeButtonLabel} href={transcribe_url} className="ghost small-button help-button" />
      # buttons.push <DoneButton label={@props.doneButtonLabel} onClick={@commitAnnotation} />

    if @props.onBadSubject?
      buttons.push <BadSubjectButton key="bad-subject-button" label={"Bad #{@props.project.term('mark')}"} className="floated-left" active={@props.badSubject} onClick={@props.onBadSubject} />
      if @props.badSubject
        buttons.push <SmallButton label='Next' key="done-button" onClick={@commitAnnotation} />

    {x,y} = @getPosition @props.subject.region
    <DraggableModal

      header  = {label}
      x={x*@props.scale.horizontal + @props.scale.offsetX}
      y={y*@props.scale.vertical + @props.scale.offsetY}
      onDone  = {@commitAnnotation}
      buttons = {buttons}>

      <div className="verify-tool-choices">
        { if @props.subject.data.task_prompt?
          <span>Original prompt: <em>{ @props.subject.data.task_prompt }</em></span>
        }
        <ul>
        { for data,i in @props.subject.data['values'][0..3]
            <li key={i}>
              <a href="javascript:void(0);" onClick={@chooseOption} data-value_index={i}>
                <ul className="choice clickable" >
                { for k,v of data
                    # Label should be the key in the data hash unless it's a single-value hash with key 'value':
                    label = if k != 'value' or (_k for _k,_v of data).length > 1 then k else ''
                    # TODO: hack to approximate a friendly label in emigrant; should pull from original label:
                    label = label.replace(/em_/,'')
                    label = label.replace(/_/g, ' ')
                    <li key={k}><span className="label">{label}</span> <span className="value">{v}</span></li>
                }
                </ul>
              </a>
              { if @props.workflow.subjects_editable
                 <SmallButton label='Edit' className="edit-button" key="edit-button" onClick={@editAnnotation.bind @, data} />
              }
            </li>
        }
        </ul>
      </div>

    </DraggableModal>

module.exports = VerifyTool

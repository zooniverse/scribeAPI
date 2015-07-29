React           = require 'react'
DraggableModal  = require '../../../draggable-modal'

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

  render: ->
    # return null unless @props.viewerSize? && @props.subject?
    # return null if ! @props.scale? || ! @props.scale.horizontal?
    return null if @props.loading # hide verify tool while loading image

    val = @state.annotation[@props.annotation_key] ? ''

    label = @props.task.instruction
    if ! @props.standalone
      label = @props.label ? ''

    {x,y} = @getPosition @props.subject.region
    console.log "verify tool rendering with scale: ", @props.scale, x, x*@props.scale.horizontal, y, y*@props.scale.vertical
    <DraggableModal
      
      header  = {label}
      x={x*@props.scale.horizontal}
      y={y*@props.scale.vertical}
      onDone  = {@commitAnnotation} >

      <div className="verify-tool-choices">
        { if @props.subject.data.task_prompt?
          <span>Original prompt: <em>{ @props.subject.data.task_prompt }</em></span>
        }
        <ul>
        { for data,i in @props.subject.data['values']
            <li key={i}>
              <a href="javascript:void(0);" onClick={@chooseOption} data-value_index={i}>
                <ul className="choice clickable" >
                { for k,v of data
                    # Label should be the key in the data hash unless it's a single-value hash with key 'value':
                    label = if k != 'value' or (_k for _k,_v of data).length > 1 then k else ''
                    <li key={k}><span>{label}</span> {v}</li>
                }
                </ul>
              </a>
            </li>
        }
        </ul>
      </div>
      
    </DraggableModal>

module.exports = VerifyTool

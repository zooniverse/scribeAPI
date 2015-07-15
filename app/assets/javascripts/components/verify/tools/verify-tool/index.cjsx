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

  render: ->
    # return null unless @props.viewerSize? && @props.subject?
    return null if ! @props.scale? || ! @props.scale.horizontal?

    # console.log "VerifyTool#render ", @props.scale.horizontal

    # If user has set a custom position, position based on that:
    # console.log "TextTool#render pos", @state

    val = @state.annotation[@props.annotation_key] ? ''

    label = @props.task.instruction
    if ! @props.standalone
      label = @props.label ? ''

    transX = parseFloat(@props.subject.region.x) * parseFloat(@props.scale.horizontal)
    # console.log "translating x,y: ", (@props.subject.region.x + 0), (@props.scale.horizontal + 0), transX
    transY = Math.round @props.subject.region.y * @props.scale.vertical
    # console.log " ...translating x,y: ", (@props.subject.region.y + 0), (@props.scale.vertical + 0), transY

    style =
      left: "#{@state.dx*@props.scale.horizontal}px"
      top: "#{@state.dy*@props.scale.vertical}px"

    <DraggableModal
      
      header  = {label}
      x       = {transX}
      y       = {transY}
      onDone  = {@commitAnnotation} >

      <div className="verify-tool-choices">
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

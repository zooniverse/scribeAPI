# @cjsx React.DOM
React           = require 'react'
Draggable       = require '../../../../lib/draggable'
DoneButton      = require './done-button'

VerifyTool = React.createClass
  displayName: 'VerifyTool'

  handleInitStart: (e) ->
    # console.log 'handleInitStart() ', ['INPUT','TEXTAREA'].indexOf(e.target.nodeName) >= 0, $(e.target), $(e.target).parents('a'), $(e.target).parents('a').length > 0
    @setState preventDrag: false
    if ['INPUT','TEXTAREA'].indexOf(e.target.nodeName) >= 0 || $(e.target).parents('a').length > 0
      @setState preventDrag: true
      
    @setState
      xClick: e.pageX - $('.transcribe-tool').offset().left
      yClick: e.pageY - $('.transcribe-tool').offset().top

  shouldComponentUpdate: ->
    # console.log "VerifyTool#shouldComponentUpdate", (@props.subject.region.x + 0), (@props.scale.horizontal + 0)
    true

  handleInitDrag: (e, delta) ->

    return if @state.preventDrag # not too happy about this one

    dx = e.pageX - @state.xClick - window.scrollX
    dy = e.pageY - @state.yClick # + window.scrollY

    @setState
      dx: dx
      dy: dy #, =>
      dragged: true

  handleDragged: (pos) ->
    # console.log "handle dragged: ", x, y
    @setState
      dx: pos.x,
      dy: pos.y

  getInitialState: ->
    viewerSize: @props.viewerSize
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
      # console.log "TextTool#updatePosition setting state: ", @state

  commitAnnotation: ->
    @props.onComplete @state.annotation

  handleChange: (e) ->
    @state.annotation[@props.annotation_key] = e.target.value
    @forceUpdate()

  handleKeyPress: (e) ->

    if [13].indexOf(e.keyCode) >= 0 # ENTER:
      @commitAnnotation()
      e.preventDefault()

    # else if [27].indexOf(e.keyCode) >= 0 # ESC: 
      # cancel ann? 

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

    tool_content =
      <div className="verify-tool-choices">
        <label>{label}</label>
        <ul>
        { for data,i in @props.subject.data['values']
            <li>
              <a href="javascript:void(0);" onClick={@chooseOption} data-value_index={i}>
                <ul className="choice clickable" >
                { for k,v of data
                    # Label should be the key in the data hash unless it's a single-value hash with key 'value':
                    label = if k != 'value' or (_k for _k,_v of data).length > 1 then k else ''
                    <li><span>{label}</span> {v}</li>
                }
                </ul>
              </a>
            </li>
        }
        </ul>
      </div>

    transX = parseFloat(@props.subject.region.x) * parseFloat(@props.scale.horizontal)
    # console.log "translating x,y: ", (@props.subject.region.x + 0), (@props.scale.horizontal + 0), transX
    transY = Math.round @props.subject.region.y * @props.scale.vertical
    # console.log " ...translating x,y: ", (@props.subject.region.y + 0), (@props.scale.vertical + 0), transY

    <Draggable
      onDrag  = {@handleDragged}
      x       = {transX}
      y       = {transY}
      inst    = "verify tool"
      ref     = "inputWrapper0">

      <div className="transcribe-tool">
        <div className="left">
          { tool_content }
        </div>
        <div className="right">
          <DoneButton onClick={@commitAnnotation} />
        </div>
      </div>
    </Draggable>

module.exports = VerifyTool

# @cjsx React.DOM
React = require 'react'
Draggable       = require '../../../../lib/draggable'
DoneButton      = require './done-button'

TextTool = React.createClass
  displayName: 'TextTool'

  handleInitStart: (e) ->
    # console.log 'handleInitStart() '
    @setState preventDrag: false
    if e.target.nodeName is "INPUT" or e.target.nodeName is "TEXTAREA"
      @setState preventDrag: true
      
    @setState
      xClick: e.pageX - $('.transcribe-tool').offset().left
      yClick: e.pageY - $('.transcribe-tool').offset().top

  handleInitDrag: (e) ->

    return if @state.preventDrag # not too happy about this one

    dx = e.pageX - @state.xClick - window.scrollX
    dy = e.pageY - @state.yClick - window.scrollY

    @setState
      dx: dx
      dy: dy #, =>
      dragged: true

  getInitialState: ->
    viewerScale: null

  getDefaultProps: ->
    annotation: {}
    task: null
    subject: null
   
  componentWillReceiveProps: ->
    @setState


  onViewerResize: (size) ->
    return null if @state.dragged

    scale = size.scale.horizontal

    dx = @props.subject.location.x * scale
    dy = ( @props.subject.location.y + @props.subject.location.h ) * scale

    @setState
      viewerScale: scale # cause horiz should = vert...
      dx: dx
      dy: dy
      # viewerWidth: size.w
      # viewerHeight: size.h
      

  handleInputChange: (e) ->
    console.log "handle input change: ", e

  handleClick: (e) ->
    console.log "click: ", e

  handleFocus: (e) ->
    console.log "focus: ", e

  render: ->
    return null if ! @state.viewerScale?

    # console.log 'render()'
    # console.log "[left, top] = [#{@state.dx}, #{@state.dy}]"
    console.log "TextTool#render: ", @state, @props.task.instruction
    
    style =
      left: @state.dx
      top: @state.dy

    <div className="transcribe-tool-container">
      <Draggable
        onStart = {@handleInitStart}
        onDrag  = {@handleInitDrag}
        onEnd   = {@handleInitRelease}>

        <div className="transcribe-tool" style={style}>
          <div className="left">
            <div className="input-field active">
              <label>{@props.task.instruction}</label>
              <input type="text" onFocus={@handleFocus} onClick={@handleClick} onChange={@handleInputChange}/>
            </div>
          </div>
          <div className="right">
            <DoneButton />
          </div>
        </div>
      </Draggable>
    </div>

module.exports = TextTool

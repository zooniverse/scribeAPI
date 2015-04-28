# @cjsx React.DOM
React = require 'react'
Draggable = require '../lib/draggable'
# ResizeButton = require './mark/resize-button'

RowFocusTool = React.createClass
  displayName: 'RowFocusTool'

  statics:
    defaultValues: ->
      @initStart arguments...

    initStart: ->
      @initMove arguments...

    initMove: ({x, y}) ->
      {x, y}

  getInitialState: ->
    # # DEBUG CODE
    # console.log "PROPS [#{@props.mark.yUpper},#{@props.mark.yLower}]"
    # console.log "INITIAL (STATE.X, STATE.Y): (#{Math.round @props.mark.x},#{Math.round @props.mark.y})"
    centerX: @props.mark.x
    centerY: @props.mark.y
    markHeight: @props.defaultMarkHeight
    fillColor: 'rgba(0,0,0,0.5)'
    strokeColor: 'rgba(0,0,0,0.5)'
    strokeWidth: 0
    yUpper: @props.mark.yUpper
    yLower: @props.mark.yLower
    markHeight: @props.mark.yLower - @props.mark.yUpper

    markComplete: false
    transcribeComplete: false

  componentWillReceiveProps: ->
    @setState
      yUpper: @props.mark.yUpper
      yLower: @props.mark.yLower
      centerX: @props.mark.x
      centerY: @props.mark.y
      markHeight: @props.mark.yLower - @props.mark.yUpper, =>
        @forceUpdate()

  handleToolProgress: ->
    if @state.markComplete is false
      # console.log 'MARK COMPLETE!'
      @setState markComplete: true
    else
      # console.log 'TRANSCRIBE COMPLETE!'
      @setState transcribeComplete: true

  render: ->
    # console.log 'mark: ', @props.mark
    markHeight = @props.mark.yLower - @props.mark.yUpper
    <g
      className = "point drawing-tool"
      transform = {"translate(#{Math.ceil @state.strokeWidth}, #{Math.round( @props.mark.y - markHeight/2 ) })"}
      data-disabled = {@props.disabled || null}
      data-selected = {@props.selected || null}
    >

      <Draggable
        onStart = {@props.handleMarkClick.bind @props.mark}
        onDrag = {@props.handleDragMark} >
        <g>
          <defs>
            <linearGradient
              id="upperGradient"
              x1="0"
              y1="0"
              x2="0"
              y2="1"
              spreadMethod="reflect" >
              <stop stopColor="#000" offset="0.5" stopOpacity="0.6"/>
              <stop stopColor="#000" offset="1"    stopOpacity="0"/>
            </linearGradient>

            <linearGradient
              id="lowerGradient"
              x1="1"
              y1="0"
              x2="1"
              y2="1"
              spreadMethod="reflect" >
              <stop stopColor="#000" offset="0"   stopOpacity="0"/>
              <stop stopColor="#000" offset="0.5" stopOpacity="0.6"/>
            </linearGradient>

          </defs>
          <rect
            className   = "mark-rectangle"
            x           = 0
            y           = { -@state.yUpper-80 }
            viewBox     = {"0 0 #{@props.imageWidth} #{@props.imageHeight}"}
            width       = {( @props.imageWidth ) }
            height      = { Math.round(@props.mark.yUpper) }
            fill        = "rgba(0,0,0,0.6)"
          />
          <rect
            className   = "mark-rectangle"
            x           = 0
            y           = { -80 }
            viewBox     = {"0 0 #{@props.imageWidth} #{@props.imageHeight}"}
            width       = {( @props.imageWidth ) }
            height      = {80}
            fill        = "url(#upperGradient)"
          />
          <rect
            className   = "mark-rectangle"
            x           = 0
            y           = { Math.round(markHeight) }
            viewBox     = {"0 0 #{@props.imageWidth} #{@props.imageHeight}"}
            width       = {( @props.imageWidth ) }
            height      = {80}
            fill        = "url(#lowerGradient)"
          />
          <rect
            className   = "mark-rectangle"
            x           = 0
            y           = { markHeight+80 }
            viewBox     = {"0 0 #{@props.imageWidth} #{@props.imageHeight}"}
            width       = { @props.imageWidth }
            height      = { Math.abs( Math.round(@props.imageHeight - @props.mark.yLower) ) }
            fill        = "rgba(0,0,0,0.6)"
          />
        </g>
      </Draggable>

    </g>

module.exports = RowFocusTool

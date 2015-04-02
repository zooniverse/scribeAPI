# @cjsx React.DOM

React = require 'react'
Draggable = require '../../../../lib/draggable'

SCRUBBER_WIDTH = 60
SCRUBBER_HEIGHT = 30

module.exports = React.createClass
  displayName: 'ResizeButton'

  getInitialState: ->
    fillColor: 'rgb(50,50,50)'
    strokeColor: 'rgba(0,0,0,0.5)'
    strokeWidth: 1
    width: SCRUBBER_WIDTH
    height: SCRUBBER_HEIGHT
    borderRadius: 4

  getDefaultProps: ->
    x: 0
    y: 0
    rotate: 0

  render: ->
    # unless @props.isSelected # hide button
    #   return null
  
    <Draggable 
      onStart = {@props.handleResize} 
      onDrag  = {@props.handleResize} 
    >
      <g 
        transform = "translate(#{0}, #{@props.y-SCRUBBER_HEIGHT/2}) rotate(#{@props.rotate})"
        className   = "clickable drawing-tool-resize-button" 
        stroke      = {@state.strokeColor} 
        strokeWidth = {@state.strokeWidth} >
          <rect
            rx     = {@state.borderRadius}
            ry     = {@state.borderRadius}
            width  = {@state.width}
            height = {@state.height} 
            fill   = {@state.fillColor} 
          />
      </g>
    </Draggable>

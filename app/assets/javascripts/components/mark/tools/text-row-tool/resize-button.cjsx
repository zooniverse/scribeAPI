# @cjsx React.DOM

React = require 'react'
Draggable = require '../../../../lib/draggable'

module.exports = React.createClass
  displayName: 'ResizeButton'

  getInitialState: ->
    fillColor: 'rgb(50,50,50)'
    strokeColor: 'rgba(0,0,0,0.5)'
    strokeWidth: 1
    width: @props.scrubberWidth
    height: @props.scrubberHeight
    borderRadius: 4

  render: ->
    unless @props.isSelected # hide button
      return null
  
    <Draggable 
      onStart = {@props.handleResize} 
      onDrag  = {@props.handleResize} 
    >
      <g 
        transform   = {@props.transform} 
        className   = "resize-button" 
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

# @cjsx React.DOM

React = require 'react'
Draggable = require '../lib/draggable'

module.exports = React.createClass
  displayName: 'ResizeButton'

  getInitialState: ->
    fillColor: 'rgb(50,50,50)'
    strokeColor: 'rgba(0,0,0,0.5)'
    strokeWidth: 1
    scrubberWidth: @props.scrubberWidth
    scrubberHeight: @props.scrubberHeight

  render: ->
    unless @props.isSelected # hide button
      return null
  
    <Draggable 
      onStart = {@props.handleResize} 
      onDrag  = {@props.handleResize} 
    >
      <g 
        transform   = {@props.transform} 
        className   = "clickable drawing-tool-resize-button" 
        stroke      = {@state.strokeColor} 
        strokeWidth = {@state.strokeWidth} >
          <rect
            width  = {@state.scrubberWidth}
            height = {@state.scrubberHeight} 
            fill   = {@state.fillColor} 
          />
      </g>
    </Draggable>

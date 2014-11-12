# @cjsx React.DOM

React = require 'react'

module.exports = React.createClass
  displayName: 'DoneCheckbox'

  getInitialState: ->
    fillColor: 'rgba(0,0,0,0.2)'
    strokeColor: 'rgba(0,0,0,0.5)'
    strokeWidth: 1
    width: 30
    height: 30

  render: ->
    <g 
      onClick     = {@props.handleMarkDone}
      transform   = {@props.transform} 
      className   = "clickable drawing-tool-done-button" 
      stroke      = {@state.strokeColor} 
      strokeWidth = {@state.strokeWidth} >
        <rect
          width  = {@state.width}
          height = {@state.height} 
          fill   = {@state.fillColor} 
        />
    </g>

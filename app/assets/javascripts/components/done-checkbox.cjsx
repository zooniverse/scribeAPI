# @cjsx React.DOM

React = require 'react'

module.exports = React.createClass
  displayName: 'DoneCheckbox'

  getInitialState: ->
    fillColor: '#26baff'
    strokeColor: '#000'
    strokeWidth: 1
    width: 25
    height: 25

  render: ->
    <g 
      transform   = {@props.transform} 
      className   = "clickable drawing-tool-done-checkmark" 
      stroke      = {@state.strokeColor} 
      strokeWidth = {@state.strokeWidth} >
        <rect
          width  = {@state.width}
          height = {@state.height} 
          fill   = {@state.fillColor} 
        />
    </g>

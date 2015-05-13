React = require 'react'
Draggable = require 'lib/draggable'

RADIUS = 5
OVERSHOOT = 4

module.exports = React.createClass
  displayName: 'DragHandle'

  render: ->

    <Draggable onDrag = {@props.onDrag} >
      <circle className="mark-tool resize-button" r={RADIUS} fill="red" cx="#{@props.x}", cy="#{@props.y}"} stroke="transparent" />
    </Draggable>

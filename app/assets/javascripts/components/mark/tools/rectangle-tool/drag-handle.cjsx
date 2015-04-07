React = require 'react'
Draggable = require 'lib/draggable'

RADIUS = 10
OVERSHOOT = 4

module.exports = React.createClass
  displayName: 'DragHandle'

  render: ->

    <Draggable onDrag = {@props.onDrag} >
      <circle className="drag-handle" r={RADIUS} fill="red" cx="#{@props.x}", cy="#{@props.y}"} stroke="transparent" />
    </Draggable>
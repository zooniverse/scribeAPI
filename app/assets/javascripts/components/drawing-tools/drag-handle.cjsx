React = require 'react'
Draggable = require '../../lib/draggable'

RADIUS = 4
OVERSHOOT = 4

module.exports = React.createClass
  displayName: 'DragHandle'

  render: ->
    style =
      fill: 'currentColor'
      stroke: 'transparent'
      strokeWidth: OVERSHOOT
      transform: """
        translate(#{@props.x}, #{@props.y})
        scale(#{1 / @props.scale.horizontal}, #{1 / @props.scale.vertical})
      """

    <Draggable onStart={@props.onStart} onDrag={@props.onDrag} onEnd={@props.onEnd}>
      <circle className="drag-handle" r={RADIUS} {...style} />
    </Draggable>

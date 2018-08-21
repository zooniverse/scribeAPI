React     = require 'react'
Draggable = require 'lib/draggable'

RADIUS = 8
STROKE_COLOR = 'white'
FILL_COLOR = 'black'
STROKE_WIDTH = 1.5

DESTROY_TRANSITION_DURATION = 0

module.exports = React.createClass
  displayName: 'DragHandle'

  getDefaultProps: ->
    x: 0
    y: 0
    rotate: 0

  render: ->
    transform = "
      translate(#{@props.position.x}, #{@props.position.y})
      rotate(#{@props.rotate})
      scale(#{1 / @props.tool.props.xScale}, #{1 / @props.tool.props.yScale})
    "

    <Draggable onDrag = {@props.onDrag}>
      <g
        className="mark-tool resize-button"
        transform={transform}
        stroke={STROKE_COLOR}
        strokeWidth={STROKE_WIDTH}
      >
        <circle r={RADIUS} fill={FILL_COLOR} />
      </g>
    </Draggable>

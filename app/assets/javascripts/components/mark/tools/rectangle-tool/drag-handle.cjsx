React = require 'react'
Draggable = require 'lib/draggable'

RADIUS = 4
STROKE_COLOR = '#fff'
FILL_COLOR = '#000'
STROKE_WIDTH = 1.5

OVERSHOOT = 4

module.exports = React.createClass
  displayName: 'DragHandle'

  render: ->
    scale = (@props.tool.props.xScale + @props.tool.props.yScale) / 2

    <Draggable onDrag = {@props.onDrag} onEnd={@props.onEnd}>
      <g
        fill={FILL_COLOR}
        stroke={STROKE_COLOR}
        strokeWidth={STROKE_WIDTH/scale}
      >
        <circle
          className="mark-tool resize-button"
          r={RADIUS/scale}
          cx="#{@props.x}",
          cy="#{@props.y}"}
        />
      </g>
    </Draggable>

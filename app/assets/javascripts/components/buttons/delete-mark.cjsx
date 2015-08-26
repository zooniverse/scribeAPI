React = require 'react'

RADIUS = 8
STROKE_COLOR = '#000'
FILL_COLOR = '#f00'
STROKE_WIDTH = 1.5

CROSS_PATH = "
  M #{-1 * RADIUS * 0.7 } 0
  L #{RADIUS * 0.7 } 0
  M 0 #{-1 * RADIUS * 0.7 }
  L 0 #{RADIUS * 0.7 }
"

module.exports = React.createClass
  displayName: 'DeleteButton'

  getDefaultProps: ->
    x: 0
    y: 0
    rotate: 0

  render: ->

    transform = "
      translate(#{@props.x}, #{@props.y})
      rotate(#{@props.rotate})
      scale(#{1 / @props.scale}, #{1 / @props.scale})
    "
    <g className="mark-tool delete-button" transform={transform} stroke={STROKE_COLOR} strokeWidth={STROKE_WIDTH} onClick={@props.onClick}>
      <circle r={RADIUS} fill={FILL_COLOR} />
      <path d={CROSS_PATH} transform="rotate(45)" />
    </g>


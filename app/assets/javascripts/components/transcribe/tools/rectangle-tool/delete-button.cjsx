React = require 'react'

RADIUS = 8
STROKE_COLOR = 'white'
FILL_COLOR = 'black'
STROKE_WIDTH = 1.5

CROSS_PATH = "
  M #{-1 * RADIUS * 0.7 } 0
  L #{RADIUS * 0.7 } 0
  M 0 #{-1 * RADIUS * 0.7 }
  L 0 #{RADIUS * 0.7 }
"

DESTROY_TRANSITION_DURATION = 0

module.exports = React.createClass
  displayName: 'DeleteButton'

  getDefaultProps: ->
    x: 0
    y: 0
    rotate: 0

  render: ->

    console.log "delete props", @props
    transform = "
      translate(#{@props.x+40}, #{@props.y-40})
      rotate(#{@props.rotate})
      scale(#{1 / @props.tool.props.xScale}, #{1 / @props.tool.props.yScale})
    "

    <g className="clickable drawing-tool-delete-button" transform={transform} stroke={STROKE_COLOR} strokeWidth={STROKE_WIDTH} onClick={@destroyTool}>
      <circle r={RADIUS} fill={FILL_COLOR} />
      <path d={CROSS_PATH} transform="rotate(45)" />
    </g>

  destroyTool: ->
    @props.tool.setState destroying: true, =>
      setTimeout @props.tool.props.onDestroy, DESTROY_TRANSITION_DURATION

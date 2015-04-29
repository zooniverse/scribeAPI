React     = require 'react'
Draggable = require 'lib/draggable'

RADIUS = 8
STROKE_COLOR = 'white'
FILL_COLOR = '#f60'
STROKE_WIDTH = 1.5

DESTROY_TRANSITION_DURATION = 0

module.exports = React.createClass
  displayName: 'TranscribeButton'

  getDefaultProps: ->
    x: 0
    y: 0
    rotate: 0

  render: ->
    # console.log 'SCALE: ', @props.tool.props.xScale
    transform = "
      translate(#{@props.position.x-RADIUS}, #{@props.position.y-2*RADIUS*@props.tool.props.yScale})
      rotate(#{@props.rotate})
      scale(#{RADIUS*@props.tool.props.xScale}, #{RADIUS*@props.tool.props.yScale})
    "

    <g className="clickable drawing-tool-transcribe-button">
      <path transform={transform} stroke="none" fill={FILL_COLOR} d="M0 0v2h.5c0-.55.45-1 1-1h1.5v5.5c0 .28-.22.5-.5.5h-.5v1h4v-1h-.5c-.28 0-.5-.22-.5-.5v-5.5h1.5c.55 0 1 .45 1 1h.5v-2h-8z" />
    </g>

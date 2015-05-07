React     = require 'react'
Draggable = require 'lib/draggable'

# BUTTON PARAMS
BUTTON_HEI = 18
BUTTON_WID = 36

RADIUS = 20
STROKE_COLOR = 'white'
FILL_COLOR = '#f60'
STROKE_WIDTH = 0.5

DESTROY_TRANSITION_DURATION = 0

module.exports = React.createClass
  displayName: 'TranscribeButton'

  getDefaultProps: ->
    x: 0
    y: 0
    rotate: 0

  render: ->
    console.log "SCALE: scale(#{1 / @props.tool.props.xScale}, #{1 / @props.tool.props.yScale})"

    transform = "
      translate(#{@props.position.x-BUTTON_WID}, #{@props.position.y-2*BUTTON_HEI*@props.tool.props.yScale})
      rotate(#{@props.rotate})
      scale(#{1 / @props.tool.props.xScale}, #{1 / @props.tool.props.yScale})
    "

    <Draggable onEnd={@props.onDrag}>
      <g
        className="mark-tool transcribe-button"
        transform={"
          translate(#{@props.position.x-BUTTON_WID}, #{@props.position.y-2*BUTTON_HEI*@props.tool.props.yScale})
          rotate(#{@props.rotate})
        "}
      >
        <rect
          stroke="none"
          transform="scale(#{1 / @props.tool.props.xScale}, #{1 / @props.tool.props.yScale})"
          fill="rgba(0,0,0,0)"
          width="36"
          height="18"
          x="0"
          y="0"
          rx="0"
          ry="0"
        />
        <path
          stroke="none"
          fill={FILL_COLOR}
          transform="scale(#{1 / @props.tool.props.xScale}, #{1 / @props.tool.props.yScale})"
          d="m 12,15 -3,3 21,0 0,-3 z m 5,-5 -3,3 22,0 0,-3 z M 22,5 19,8 30,8 30,5 z M 14,0 11,3 15,7 18,4 z M 9.0249385,4.975061 0,14 l 0,4 4,0 9,-9 z"
        />

      </g>
    </Draggable>

'''
# CHECKMARK ICON
<rect
  stroke="none"
  fill="rgba(0,0,0,0)"
  width="28"
  height="20"
  x="0"
  y="0"
  transform="scale(0.5,0.5)"
  rx="0.0025846157"
  ry="0.0025263159"
/>
<path
  stroke="none"
  fill="rgb(63,87,101)"
  d="m 5.52,9.53 c 0,0 -5.04,-4.86 -5.04,-4.86 0,0 1.44,-1.39 1.44,-1.39 0,0 3.6,3.47 3.6,3.47 0,0 6.48,-6.25 6.48,-6.25 0,0 1.44,1.39 1.44,1.39 0,0 -7.92,7.64 -7.92,7.64 z"
/>

'''

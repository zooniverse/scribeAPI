React     = require 'react'
Draggable = require 'lib/draggable'

DEBUG = false

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
        transform=
          "
            translate(#{@props.position.x},#{@props.position.y})
            scale(#{1 / @props.tool.props.xScale}, #{1 / @props.tool.props.yScale})
          "
      >

        { if false
            <rect
              stroke="none"
              transform="translate(0,#{-0.5*BUTTON_HEI})"
              fill="rgba(255,255,255,0.0)"
              width="36"
              height="18"
              x="0"
              y="0"
              rx="0"
              ry="0"
            />
            <path
              stroke="none"
              transform="translate(0,#{-0.5*BUTTON_HEI})"
              fill={FILL_COLOR}
              d="m 12,15 -3,3 21,0 0,-3 z m 5,-5 -3,3 22,0 0,-3 z M 22,5 19,8 30,8 30,5 z M 14,0 11,3 15,7 18,4 z M 9.0249385,4.975061 0,14 l 0,4 4,0 9,-9 z"
            />
        }

        {
          if DEBUG
            <circle
              x="0"
              y="0"
              r="2"
              fill="rgba(255,255,255,0.75)"
              stroke="none"
            />
        }

        <path
          className="checkbox"
          fill="rgb(200,0,0)"
          stroke="none"
          transform="translate(#{-0.5*20},#{-0.5*20})"
          d="M 4,1 C 2.338,1 1,2.338 1,4 l 0,12 c 0,1.662 1.338,3 3,3 l 12,0 c 1.662,0 3,-1.338 3,-3 L 19,4 C 19,2.338 17.662,1 16,1 L 4,1 z m 1,2 10,0 c 1.108,0 2,0.8920001 2,2 l 0,10 c 0,1.108 -0.892,2 -2,2 L 5,17 C 3.8920001,17 3,16.108 3,15 L 3,5 C 3,3.8920001 3.8920001,3 5,3 z"
        />

        <path
          className="checkmark"
          transform="translate(#{-0.5*25*@props.tool.props.xScale},#{-0.5*20*@props.tool.props.yScale})"
          d="M 5.9999998,9.4416621 0.9212221,3.4141019 2.5714288,1.7142856 l 3.428571,4.2857142 7.7142852,-8.5714283 1.714286,1.71428567 z"
          fill="rgb(0,200,0)"
          stroke="none"
        />

        <rect
          transform="translate(#{-0.5*20},#{-0.5*20})"
          fill="rgba(255,255,255,0)"
          stroke="none"
          width="18"
          height="18"
          x="0"
          y="0"
          rx="0"
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

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

  componentWillReceiveProps: ->
    console.log 'component will receive props: ', @props.markStatus, @props.locked

  render: ->

    transform = "
      translate(#{@props.position.x-BUTTON_WID}, #{@props.position.y-2*BUTTON_HEI*@props.tool.props.yScale})
      rotate(#{@props.rotate})
      scale(#{1 / @props.tool.props.xScale}, #{1 / @props.tool.props.yScale})
    "

    <Draggable onEnd={@props.onDrag}>
      <g
        className="mark-tool action-button"
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

        <g className="checkbox">
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

          <text
            x="0"
            y="0"
            fontSize="10"
            transform="translate(10,3)"
            fill="rgb(67,187,253)"
            stroke="none">

            DONE
          </text>

          <path
            fill="rgb(67,187,253)"
            stroke="none"
            transform="translate(#{-0.5*20},#{-0.5*20})"
            d="M 4,1 C 2.338,1 1,2.338 1,4 l 0,12 c 0,1.662 1.338,3 3,3 l 12,0 c 1.662,0 3,-1.338 3,-3 L 19,4 C 19,2.338 17.662,1 16,1 L 4,1 z m 1,2 10,0 c 1.108,0 2,0.8920001 2,2 l 0,10 c 0,1.108 -0.892,2 -2,2 L 5,17 C 3.8920001,17 3,16.108 3,15 L 3,5 C 3,3.8920001 3.8920001,3 5,3 z"
          />

          { if @props.markStatus is 'mark-finished'
              <path
                className="checkmark"
                transform="translate(#{-0.5*25*@props.tool.props.xScale},#{-0.5*20*@props.tool.props.yScale})"
                d="M 5.9999998,9.4416621 0.9212221,3.4141019 2.5714288,1.7142856 l 3.428571,4.2857142 7.7142852,-8.5714283 1.714286,1.71428567 z"
                fill="rgb(0,200,0)"
                stroke="none"
              />
          }

        </g>


      </g>
    </Draggable>

import React from 'react'
import Draggable from '../../../../lib/draggable.jsx'

const RADIUS = 8
const STROKE_COLOR = '#fff'
const FILL_COLOR = '#000'
const STROKE_WIDTH = 2

export default function DragHandle(props) {
  const scale =
    (props.tool.props.xScale + props.tool.props.yScale) / 2

  return (
    <Draggable onDrag={props.onDrag} onEnd={props.onEnd}>
      <g
        fill={FILL_COLOR}
        stroke={STROKE_COLOR}
        strokeWidth={STROKE_WIDTH / scale}
      >
        <circle
          className="mark-tool resize-button"
          r={RADIUS / scale}
          cx={`${props.x}`}
          cy={`${props.y}`}
        />
      </g>
    </Draggable>
  )
}

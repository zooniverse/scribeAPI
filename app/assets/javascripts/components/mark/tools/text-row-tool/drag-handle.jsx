/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react";
import createReactClass from "create-react-class";
import Draggable from "../../../../lib/draggable.jsx";

const RADIUS = 8;
const STROKE_COLOR = "white";
const FILL_COLOR = "black";
const STROKE_WIDTH = 1.5;

const DESTROY_TRANSITION_DURATION = 0;

export default createReactClass({
  displayName: "DragHandle",

  getDefaultProps() {
    return {
      x: 0,
      y: 0,
      rotate: 0
    };
  },

  render() {
    const transform = `\
translate(${this.props.position.x}, ${this.props.position.y}) \
rotate(${this.props.rotate}) \
scale(${1 / this.props.tool.props.xScale}, ${1 / this.props.tool.props.yScale})\
`;

    return (
      <Draggable onDrag={this.props.onDrag}>
        <g
          className="mark-tool resize-button"
          transform={transform}
          stroke={STROKE_COLOR}
          strokeWidth={STROKE_WIDTH}
        >
          <circle r={RADIUS} fill={FILL_COLOR} />
        </g>
      </Draggable>
    );
  }
});

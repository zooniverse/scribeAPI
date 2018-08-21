/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const Draggable = require("lib/draggable");

const RADIUS = 8;
const STROKE_COLOR = "white";
const FILL_COLOR = "black";
const STROKE_WIDTH = 1.5;

const DESTROY_TRANSITION_DURATION = 0;

module.exports = require('create-react-class')({
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

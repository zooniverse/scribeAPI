/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");

const RADIUS = 8;
const STROKE_COLOR = "#000";
const FILL_COLOR = "#f00";
const STROKE_WIDTH = 1.5;

const CROSS_PATH = `\
M ${-1 * RADIUS * 0.7} 0 \
L ${RADIUS * 0.7} 0 \
M 0 ${-1 * RADIUS * 0.7} \
L 0 ${RADIUS * 0.7}\
`;

const DESTROY_TRANSITION_DURATION = 0;

module.exports = React.createClass({
  displayName: "DeleteButton",

  getDefaultProps() {
    return {
      x: 0,
      y: 0,
      rotate: 0
    };
  },

  render() {
    const transform = `\
translate(${this.props.x + 40}, ${this.props.y - 40}) \
rotate(${this.props.rotate}) \
scale(${1 / this.props.tool.props.xScale}, ${1 / this.props.tool.props.yScale})\
`;
    return (
      <g
        className="mark-tool delete-button"
        transform={transform}
        stroke={STROKE_COLOR}
        strokeWidth={STROKE_WIDTH}
        onClick={this.destroyTool}
      >
        <circle r={RADIUS} fill={FILL_COLOR} />
        <path d={CROSS_PATH} transform="rotate(45)" />
      </g>
    );
  },

  destroyTool() {
    return this.props.tool.setState({ destroying: true }, () => {
      return setTimeout(
        this.props.tool.props.onDestroy,
        DESTROY_TRANSITION_DURATION
      );
    });
  }
});

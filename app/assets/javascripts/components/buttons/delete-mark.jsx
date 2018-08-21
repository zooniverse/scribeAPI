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
translate(${this.props.x}, ${this.props.y}) \
rotate(${this.props.rotate}) \
scale(${1 / this.props.scale}, ${1 / this.props.scale})\
`;
    return (
      <g
        className="mark-tool delete-button"
        transform={transform}
        stroke={STROKE_COLOR}
        strokeWidth={STROKE_WIDTH}
        onClick={this.props.onClick}
      >
        <circle r={RADIUS} fill={FILL_COLOR} />
        <path d={CROSS_PATH} transform="rotate(45)" />
      </g>
    );
  }
});

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const createReactClass = require("create-react-class");

const STROKE_WIDTH = 1.5;
const SELECTED_STROKE_WIDTH = 2.5;

module.exports = createReactClass({
  displayName: "DrawingToolRoot",

  statics: {
    distance(x1, y1, x2, y2) {
      return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
    }
  },

  getDefaultProps() {
    return { tool: null };
  },

  getInitialState() {
    return { destroying: false };
  },

  render() {
    const toolProps = this.props.tool.props;

    const rootProps = {
      "data-disabled": toolProps.disabled || null,
      "data-selected": toolProps.selected || null,
      "data-destroying":
        (this.props.tool.state != null
          ? this.props.tool.state.destroying
          : undefined) || null,
      style: {
        color: toolProps.color
      }
    };

    const scale = (toolProps.xScale + toolProps.yScale) / 2;

    const mainStyle = {
      fill: "transparent",
      stroke: "red",
      strokeWidth: toolProps.selected
        ? SELECTED_STROKE_WIDTH / scale
        : STROKE_WIDTH / scale
    };

    return (
      <g
        className="drawing-tool"
        data-disabled={toolProps.disabled || null}
        data-selected={toolProps.selected || null}
        data-destroying={
          (this.props.tool.state != null
            ? this.props.tool.state.destroying
            : undefined) || null
        }
        color="red"
      >
        <g
          className="drawing-tool-main"
          fill="transparent"
          stroke="#f60"
          strokeWidth={SELECTED_STROKE_WIDTH / scale}
          onMouseDown={!toolProps.disabled ? toolProps.onSelect : undefined}
        >
          {this.props.children}
        </g>
      </g>
    );
  }
});

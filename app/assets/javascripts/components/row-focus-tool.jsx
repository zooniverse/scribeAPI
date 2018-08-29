/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const React = require("react");
const Draggable = require("../lib/draggable.jsx");
// ResizeButton = require './mark/resize-button'

const createReactClass = require("create-react-class");

const RowFocusTool = createReactClass({
  displayName: "RowFocusTool",

  statics: {
    defaultValues() {
      return this.initStart(...arguments);
    },

    initStart() {
      return this.initMove(...arguments);
    },

    initMove({ x, y }) {
      return { x, y };
    }
  },

  getInitialState() {
    return {
      centerX: this.props.mark.x,
      centerY: this.props.mark.y,
      fillColor: "rgba(0,0,0,0.5)",
      strokeColor: "rgba(0,0,0,0.5)",
      strokeWidth: 0,
      yUpper: this.props.mark.yUpper,
      yLower: this.props.mark.yLower,
      markHeight: this.props.mark.yLower - this.props.mark.yUpper,

      markComplete: false,
      transcribeComplete: false
    };
  },

  componentWillReceiveProps() {
    return this.setState(
      {
        yUpper: this.props.mark.yUpper,
        yLower: this.props.mark.yLower,
        centerX: this.props.mark.x,
        centerY: this.props.mark.y,
        markHeight: this.props.mark.yLower - this.props.mark.yUpper
      },
      () => {
        return this.forceUpdate();
      }
    );
  },

  handleToolProgress() {
    if (this.state.markComplete === false) {
      return this.setState({ markComplete: true });
    } else {
      return this.setState({ transcribeComplete: true });
    }
  },

  render() {
    const markHeight = this.props.mark.yLower - this.props.mark.yUpper;
    return (
      <g
        className="point drawing-tool"
        transform={`translate(${Math.ceil(
          this.state.strokeWidth
        )}, ${Math.round(this.props.mark.y - markHeight / 2)})`}
        data-disabled={this.props.disabled || null}
        data-selected={this.props.selected || null}
      >
        <Draggable
          onStart={this.props.handleMarkClick.bind(this.props.mark)}
          onDrag={this.props.handleDragMark}
        >
          <g>
            <defs>
              <linearGradient
                id="upperGradient"
                x1="0"
                y1="0"
                x2="0"
                y2="1"
                spreadMethod="reflect"
              >
                <stop stopColor="#000" offset="0.5" stopOpacity="0.6" />
                <stop stopColor="#000" offset="1" stopOpacity="0" />
              </linearGradient>
              <linearGradient
                id="lowerGradient"
                x1="1"
                y1="0"
                x2="1"
                y2="1"
                spreadMethod="reflect"
              >
                <stop stopColor="#000" offset="0" stopOpacity="0" />
                <stop stopColor="#000" offset="0.5" stopOpacity="0.6" />
              </linearGradient>
            </defs>
            <rect
              className="mark-rectangle"
              x={0}
              y={-this.state.yUpper - 80}
              viewBox={`0 0 ${this.props.imageWidth} ${this.props.imageHeight}`}
              width={this.props.imageWidth}
              height={Math.round(this.props.mark.yUpper)}
              fill="rgba(0,0,0,0.6)"
            />
            <rect
              className="mark-rectangle"
              x={0}
              y={-80}
              viewBox={`0 0 ${this.props.imageWidth} ${this.props.imageHeight}`}
              width={this.props.imageWidth}
              height={80}
              fill="url(#upperGradient)"
            />
            <rect
              className="mark-rectangle"
              x={0}
              y={Math.round(markHeight)}
              viewBox={`0 0 ${this.props.imageWidth} ${this.props.imageHeight}`}
              width={this.props.imageWidth}
              height={80}
              fill="url(#lowerGradient)"
            />
            <rect
              className="mark-rectangle"
              x={0}
              y={markHeight + 80}
              viewBox={`0 0 ${this.props.imageWidth} ${this.props.imageHeight}`}
              width={this.props.imageWidth}
              height={Math.abs(
                Math.round(this.props.imageHeight - this.props.mark.yLower)
              )}
              fill="rgba(0,0,0,0.6)"
            />
          </g>
        </Draggable>
      </g>
    );
  }
});

module.exports = RowFocusTool;

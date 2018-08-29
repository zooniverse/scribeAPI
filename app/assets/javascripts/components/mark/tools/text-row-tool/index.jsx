/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const createReactClass = require("create-react-class");
const DrawingToolRoot = require("./root.jsx");
const Draggable = require("../../../../lib/draggable.jsx");
const DeleteButton = require("./delete-button.jsx");
const DragHandle = require("./drag-handle.jsx");
const MarkButtonMixin = require("../../../../lib/mark-button-mixin.jsx");

// DEFAULT SETTINGS
const RADIUS = 10;
const SELECTED_RADIUS = 20;
const CROSSHAIR_SPACE = 0.2;
const CROSSHAIR_WIDTH = 1;
const DELETE_BUTTON_ANGLE = 45;
const DEFAULT_HEIGHT = 100;
const MINIMUM_HEIGHT = 25;

module.exports = createReactClass({
  displayName: "TextRowTool",

  mixins: [MarkButtonMixin], // adds MarkButton and helper methods to each mark

  statics: {
    defaultValues({ x, y }) {
      return {
        x,
        y: y - DEFAULT_HEIGHT / 2, // x and y will be the initial click position (not super useful as of yet)
        yUpper: y - DEFAULT_HEIGHT / 2,
        yLower: y + DEFAULT_HEIGHT / 2
      };
    },

    initMove({ x, y }) {
      return {
        x,
        y: y - DEFAULT_HEIGHT / 2,
        yUpper: y - DEFAULT_HEIGHT / 2, // not sure if these are needed
        yLower: y + DEFAULT_HEIGHT / 2
      };
    }
  },

  getDeleteButtonPosition() {
    return {
      x: 100,
      y: (this.props.mark.yLower - this.props.mark.yUpper) / 2
    };
  },

  getUpperHandlePosition() {
    return {
      x:
        (this.props.sizeRect != null
          ? this.props.sizeRect.props.width
          : undefined) / 2,
      y: this.props.mark.yUpper - this.props.mark.y
    };
  },

  getLowerHandlePosition() {
    return {
      x:
        (this.props.sizeRect != null
          ? this.props.sizeRect.props.width
          : undefined) / 2,
      y: this.props.mark.yLower - this.props.mark.y
    };
  },

  getMarkButtonPosition() {
    // NOTE: this somehow doesn't receive props in the first couple renders and produces an error --STI
    return {
      x:
        (this.props.sizeRect != null
          ? this.props.sizeRect.props.width
          : undefined) - 100,
      y: (this.props.mark.yLower - this.props.mark.yUpper) / 2
    };
  },

  render() {
    let isPriorMark;
    if (this.state.markStatus === "mark-committed") {
      isPriorMark = true;
      this.props.disabled = true;
    }

    const classes = [];
    if (this.props.isTranscribable) {
      classes.push("transcribable");
    }
    classes.push(this.props.disabled ? "committed" : "uncommitted");

    const averageScale = (this.props.xScale + this.props.yScale) / 2;
    const crosshairSpace = CROSSHAIR_SPACE / averageScale;
    const crosshairWidth = CROSSHAIR_WIDTH / averageScale;
    const selectedRadius = SELECTED_RADIUS / averageScale;
    const radius = this.props.selected
      ? SELECTED_RADIUS / averageScale
      : RADIUS / averageScale;

    const scale = (this.props.xScale + this.props.yScale) / 2;

    return (
      <g
        tool={this}
        transform={`translate(0, ${this.props.mark.y})`}
        onMouseDown={this.handleMouseDown}
        title={this.props.mark.label}
      >
        <g
          className="text-row-tool"
          onMouseDown={!this.props.disabled ? this.props.onSelect : undefined}
        >
          <Draggable onDrag={this.handleDrag}>
            <g
              className={`tool-shape ${classes.join(" ")}`}
              dangerouslySetInnerHTML={{
                __html: `\
                  <filter id=\"dropShadow\"> \
                    <feGaussianBlur in=\"SourceAlpha\" stdDeviation=\"3\" /> \
                    <feOffset dx=\"2\" dy=\"4\" /> \
                    <feMerge> \
                      <feMergeNode /> \
                      <feMergeNode in=\"SourceGraphic\" /> \
                    </feMerge> \
                  </filter> \
                  <rect \
                    ${this.props.mark.color != null
                    ? `stroke=\"${this.props.mark.color}\"`
                    : ''} \
                    x=\"0\" \
                    y=\"0\" \
                    width=\"100%\" \
                    height=\"${this.props.mark.yLower - this.props.mark.yUpper}\" \
                    className=\"${isPriorMark ? "previous-mark" : undefined}\" \
                    filter=\"${this.props.selected ? "url(#dropShadow)" : "none"}\" \
                  />\
                `
              }}
            />
          </Draggable>
          {this.props.selected && !this.state.locked ? (
            <g>
              <DragHandle tool={this} onDrag={this.handleUpperResize} position={this.getUpperHandlePosition()} />
              <DragHandle tool={this} onDrag={this.handleLowerResize} position={this.getLowerHandlePosition()} />
              <DeleteButton tool={this} position={this.getDeleteButtonPosition()} />
            </g>
          ) : (
              undefined
            )}
          {(() => {
            // REQUIRES MARK-BUTTON-MIXIN
            if (this.props.selected || this.state.markStatus === "transcribe-enabled"
            ) {
              if (this.props.isTranscribable) {
                return this.renderMarkButton();
              }
            }
          })()}
        </g>
      </g>
    );
  },

  handleDrag(e, d) {
    if (this.state.locked) {
      return;
    }
    if (this.props.disabled) {
      return;
    }
    this.props.mark.y += d.y / this.props.yScale;
    this.props.mark.yUpper += d.y / this.props.yScale;
    this.props.mark.yLower += d.y / this.props.yScale;
    return this.props.onChange(e);
  },

  handleUpperResize(e, d) {
    this.props.mark.yUpper += d.y / this.props.yScale;
    this.props.mark.y += d.y / this.props.yScale; // fix weird resizing problem
    return this.props.onChange(e);
  },

  handleLowerResize(e, d) {
    this.props.mark.yLower += d.y / this.props.yScale;
    return this.props.onChange(e);
  },

  handleMouseDown() { }
});
// @props.onSelect @props.mark # unless @props.disabled

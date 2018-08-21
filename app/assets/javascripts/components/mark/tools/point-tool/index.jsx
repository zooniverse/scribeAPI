/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const DrawingToolRoot = require("./root");
const Draggable = require("lib/draggable");
const DeleteButton = require("../../../buttons/delete-mark");
const MarkButtonMixin = require("lib/mark-button-mixin");

// DEFAULT SETTINGS
const RADIUS = 10;
const SELECTED_RADIUS = 20;
const CROSSHAIR_SPACE = 0.2;
const CROSSHAIR_WIDTH = 1;
const DELETE_BUTTON_ANGLE = 45;

module.exports = React.createClass({
  displayName: "PointTool",

  mixins: [MarkButtonMixin],

  statics: {
    defaultValues({ x, y }) {
      return { x, y };
    },

    initMove({ x, y }) {
      return { x, y };
    }
  },

  getDeleteButtonPosition() {
    const theta = DELETE_BUTTON_ANGLE * (Math.PI / 180);
    return {
      x: (SELECTED_RADIUS / this.props.xScale) * Math.cos(theta) + 20,
      y: -1 * (SELECTED_RADIUS / this.props.yScale) * Math.sin(theta) - 20
    };
  },

  getMarkButtonPosition() {
    return {
      x: SELECTED_RADIUS / this.props.xScale,
      y: SELECTED_RADIUS / this.props.yScale
    };
  },

  handleDrag(e, d) {
    if (this.state.locked) {
      return;
    }
    if (this.props.disabled) {
      return;
    }
    this.props.mark.x += d.x / this.props.xScale;
    this.props.mark.y += d.y / this.props.yScale;
    return this.props.onChange(e);
  },

  handleMouseDown() {
    return this.props.onSelect(this.props.mark);
  }, // unless @props.disabled

  render() {
    const classes = [];
    if (this.props.isTranscribable) {
      classes.push("transcribable");
    }
    classes.push(this.props.disabled ? "committed" : "uncommitted");

    if (this.state.markStatus === "mark-committed") {
      const isPriorMark = true;
      this.props.disabled = true;
    }

    const averageScale = (this.props.xScale + this.props.yScale) / 2;

    const crosshairSpace = CROSSHAIR_SPACE / averageScale;
    const crosshairWidth = CROSSHAIR_WIDTH / averageScale;
    const selectedRadius = SELECTED_RADIUS / averageScale;

    const radius =
      this.props.selected || this.props.disabled
        ? SELECTED_RADIUS / averageScale
        : RADIUS / averageScale;

    const scale = (this.props.xScale + this.props.yScale) / 2;

    return (
      <g
        tool={this}
        transform={`translate(${this.props.mark.x}, ${this.props.mark.y})`}
        onMouseDown={this.handleMouseDown}
        title={this.props.mark.label}
      >
        <g className="point-tool">
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
\
<g ${
                  this.props.mark.color != null
                    ? `stroke=\"${this.props.mark.color}\"`
                    : undefined
                } > \
<line x1=\"0\" y1=\"${-1 *
                  crosshairSpace *
                  selectedRadius}\" x2=\"0\" y2=\"${-1 *
                  selectedRadius}\" strokeWidth=\"${crosshairWidth}\" /> \
<line x1=\"${-1 * crosshairSpace * selectedRadius}\" y1=\"0\" x2=\"${-1 *
                  selectedRadius}\" y2=\"0\" strokeWidth=\"${crosshairWidth}\" /> \
<line x1=\"0\" y1=\"${crosshairSpace *
                  selectedRadius}\" x2=\"0\" y2=\"${selectedRadius}\" strokeWidth=\"${crosshairWidth}\" /> \
<line x1=\"${crosshairSpace *
                  selectedRadius}\" y1=\"0\" x2=\"${selectedRadius}\" y2=\"0\" strokeWidth=\"${crosshairWidth}\" /> \
</g> \
\
<circle \
${
                  this.props.mark.color != null
                    ? `stroke=\"${this.props.mark.color}\"`
                    : undefined
                } \
r=\"${radius}\" \
filter=\"${this.props.selected ? "url(#dropShadow)" : "none"}\" \
/>\
`
              }}
            />
          </Draggable>
          {this.props.selected ? (
            <DeleteButton
              onClick={this.props.onDestroy}
              scale={scale}
              x={this.getDeleteButtonPosition().x}
              y={this.getDeleteButtonPosition().y}
            />
          ) : (
            undefined
          )}
          {(() => {
            // REQUIRES MARK-BUTTON-MIXIN
            if (
              this.props.selected ||
              this.state.markStatus === "transcribe-enabled"
            ) {
              if (this.props.isTranscribable) {
                return this.renderMarkButton();
              }
            }
          })()}
        </g>
      </g>
    );
  }
});

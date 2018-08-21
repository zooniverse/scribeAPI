/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const Draggable = require("lib/draggable");
const DragHandle = require("./drag-handle");
const DeleteButton = require("../../../buttons/delete-mark");
const MarkButtonMixin = require("lib/mark-button-mixin");

const MINIMUM_SIZE = 15;
const DELETE_BUTTON_ANGLE = 45;
const DELETE_BUTTON_DISTANCE_X = 12;
const DELETE_BUTTON_DISTANCE_Y = 0;
const DEBUG = false;

module.exports = React.createClass({
  displayName: "RectangleTool",

  mixins: [MarkButtonMixin],

  propTypes: {
    // key:  React.PropTypes.number.isRequired
    mark: React.PropTypes.object.isRequired
  },

  initCoords: null,

  statics: {
    defaultValues({ x, y }) {
      return {
        x,
        y,
        width: 0,
        height: 0
      };
    },

    initStart({ x, y }, mark) {
      this.initCoords = { x, y };
      return { x, y };
    },

    initMove(cursor, mark) {
      let height, width, x, y;
      if (cursor.x > this.initCoords.x) {
        width = cursor.x - mark.x;
        ({ x } = mark);
      } else {
        width = this.initCoords.x - cursor.x;
        ({ x } = cursor);
      }

      if (cursor.y > this.initCoords.y) {
        height = cursor.y - mark.y;
        ({ y } = mark);
      } else {
        height = this.initCoords.y - cursor.y;
        ({ y } = cursor);
      }

      return { x, y, width, height };
    },

    initValid(mark) {
      return mark.width > MINIMUM_SIZE && mark.height > MINIMUM_SIZE;
    },

    // This callback is called on mouseup to override mark properties (e.g. if too small)
    initRelease(coords, mark, e) {
      mark.width = Math.max(mark.width, MINIMUM_SIZE);
      mark.height = Math.max(mark.height, MINIMUM_SIZE);
      return mark;
    }
  },

  getInitialState() {
    const { mark } = this.props;
    if (mark.status == null) {
      mark.status = "mark";
    }
    ({ mark });
    // set up the state in order to caluclate the polyline as rectangle
    const x1 = this.props.mark.x;
    const x2 = x1 + this.props.mark.width;
    const y1 = this.props.mark.y;
    const y2 = y1 + this.props.mark.height;

    return {
      pointsHash: this.createRectangleObjects(x1, x2, y1, y2),

      buttonDisabled: false,
      lockTool: false
    };
  },

  componentWillReceiveProps(newProps) {
    const x1 = newProps.mark.x;
    const x2 = x1 + newProps.mark.width;
    const y1 = newProps.mark.y;
    const y2 = y1 + newProps.mark.height;

    return this.setState({
      pointsHash: this.createRectangleObjects(x1, x2, y1, y2)
    });
  },

  createRectangleObjects(x1, x2, y1, y2) {
    let HX, HY, LX, LY, pointsHash;
    if (x1 < x2) {
      LX = x1;
      HX = x2;
    } else {
      LX = x2;
      HX = x1;
    }

    if (y1 < y2) {
      LY = y1;
      HY = y2;
    } else {
      LY = y2;
      HY = y1;
    }

    // PB: L and H seem to denote Low and High values of x & y, so:
    // LL: upper left
    // HL: upper right
    // HH: lower right
    // LH: lower left
    return (pointsHash = {
      handleLLDrag: [LX, LY],
      handleHLDrag: [HX, LY],
      handleHHDrag: [HX, HY],
      handleLHDrag: [LX, HY]
    });
  },

  handleMainDrag(e, d) {
    if (this.state.locked) {
      return;
    }
    if (this.props.disabled) {
      return;
    }
    this.props.mark.x += d.x / this.props.xScale;
    this.props.mark.y += d.y / this.props.yScale;
    this.assertBounds();
    return this.props.onChange(e);
  },

  dragFilter(key) {
    if (key === "handleLLDrag") {
      return this.handleLLDrag;
    }
    if (key === "handleLHDrag") {
      return this.handleLHDrag;
    }
    if (key === "handleHLDrag") {
      return this.handleHLDrag;
    }
    if (key === "handleHHDrag") {
      return this.handleHHDrag;
    }
  },

  handleLLDrag(e, d) {
    this.props.mark.x += d.x / this.props.xScale;
    this.props.mark.width -= d.x / this.props.xScale;
    this.props.mark.y += d.y / this.props.yScale;
    this.props.mark.height -= d.y / this.props.yScale;
    return this.props.onChange(e);
  },

  handleLHDrag(e, d) {
    this.props.mark.x += d.x / this.props.xScale;
    this.props.mark.width -= d.x / this.props.xScale;
    this.props.mark.height += d.y / this.props.yScale;
    return this.props.onChange(e);
  },

  handleHLDrag(e, d) {
    this.props.mark.width += d.x / this.props.xScale;
    this.props.mark.y += d.y / this.props.yScale;
    this.props.mark.height -= d.y / this.props.yScale;
    return this.props.onChange(e);
  },

  handleHHDrag(e, d) {
    this.props.mark.width += d.x / this.props.xScale;
    this.props.mark.height += d.y / this.props.yScale;
    return this.props.onChange(e);
  },

  assertBounds() {
    this.props.mark.x = Math.min(
      this.props.sizeRect.props.width - this.props.mark.width,
      this.props.mark.x
    );
    this.props.mark.y = Math.min(
      this.props.sizeRect.props.height - this.props.mark.height,
      this.props.mark.y
    );

    this.props.mark.x = Math.max(0, this.props.mark.x);
    this.props.mark.y = Math.max(0, this.props.mark.y);

    this.props.mark.width = Math.max(this.props.mark.width, MINIMUM_SIZE);
    return (this.props.mark.height = Math.max(
      this.props.mark.height,
      MINIMUM_SIZE
    ));
  },

  validVert(y, h) {
    return y >= 0 && y + h <= this.props.sizeRect.props.height;
  },

  validHoriz(x, w) {
    return x >= 0 && x + w <= this.props.sizeRect.props.width;
  },

  getDeleteButtonPosition() {
    const points = this.state.pointsHash["handleHLDrag"];
    let x = points[0] + DELETE_BUTTON_DISTANCE_X / this.props.xScale;
    let y = points[1] + DELETE_BUTTON_DISTANCE_Y / this.props.yScale;
    x = Math.min(x, this.props.sizeRect.props.width - 15 / this.props.xScale);
    y = Math.max(y, 15 / this.props.yScale);
    return { x, y };
  },

  getMarkButtonPosition() {
    const points = this.state.pointsHash["handleHHDrag"];
    return {
      x: Math.min(
        points[0],
        this.props.sizeRect.props.width - 40 / this.props.xScale
      ),
      y: Math.min(
        points[1] + 20 / this.props.yScale,
        this.props.sizeRect.props.height - 15 / this.props.yScale
      )
    };
  },

  handleMouseDown() {
    return this.props.onSelect(this.props.mark);
  },

  normalizeMark() {
    if (this.props.mark.width < 0) {
      this.props.mark.x += this.props.mark.width;
      this.props.mark.width *= -1;
    }

    if (this.props.mark.height < 0) {
      this.props.mark.y += this.props.mark.height;
      this.props.mark.height *= -1;
    }

    return this.props.onChange();
  },

  render() {
    const classes = [];
    if (this.props.isTranscribable) {
      classes.push("transcribable");
    }
    if (this.props.interim) {
      classes.push("interim");
    }
    classes.push(this.props.disabled ? "committed" : "uncommitted");
    if (this.checkLocation()) {
      classes.push("tanscribing");
    }

    const x1 = this.props.mark.x;
    const { width } = this.props.mark;
    const x2 = x1 + width;
    const y1 = this.props.mark.y;
    const { height } = this.props.mark;
    const y2 = y1 + height;

    const scale = (this.props.xScale + this.props.yScale) / 2;

    const points = [
      [x1, y1].join(","),
      [x2, y1].join(","),
      [x2, y2].join(","),
      [x1, y2].join(","),
      [x1, y1].join(",")
    ].join("\n");

    return (
      <g
        tool={this}
        onMouseDown={this.props.onSelect}
        title={this.props.mark.label}
      >
        <g className={`rectangle-tool${this.props.disabled ? " locked" : ""}`}>
          <Draggable onDrag={this.handleMainDrag}>
            <g
              className={`tool-shape ${classes.join(" ")}`}
              key={points}
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
<polyline \
${
                  this.props.mark.color != null
                    ? `stroke=\"${this.props.mark.color}\"`
                    : undefined
                } \
points=\"${points}\" \
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
              x={this.getDeleteButtonPosition(this.state.pointsHash).x}
              y={this.getDeleteButtonPosition(this.state.pointsHash).y}
            />
          ) : (
            undefined
          )}
          {this.props.selected && !this.props.disabled ? (
            <g>
              {(() => {
                const result = [];

                for (let key in this.state.pointsHash) {
                  const value = this.state.pointsHash[key];
                  result.push(
                    <DragHandle
                      key={key}
                      tool={this}
                      x={value[0]}
                      y={value[1]}
                      onDrag={this.dragFilter(key)}
                      onEnd={this.normalizeMark}
                    />
                  );
                }

                return result;
              })()}
            </g>
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

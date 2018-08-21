/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const React = require("react");
const Draggable = require("lib/draggable");
const DoneButton = require("./done-button");
const inputComponents = require("../../input-components");

const TextTool = require('create-react-class')({
  displayName: "SingleTool",

  getInitialState() {
    return {
      viewerSize: this.props.viewerSize,
      annotation: {
        value: ""
      }
    };
  },

  getDefaultProps() {
    return {
      annotation: {},
      task: null,
      subject: null,
      clickOffsetX: 0,
      clickOffsetY: 0
    };
  },

  componentWillReceiveProps() {
    return this.setState({
      annotation: this.props.annotation
    });
  },

  componentDidMount() {
    // not sure if this does anything? --STI
    return this.updatePosition();
  },

  handleInitStart(e, d) {
    // prevent dragging from non-divs (a bit hacky) --STI
    this.setState({ preventDrag: e.target.nodeName !== "DIV" });

    this.props.clickOffsetX =
      e.nativeEvent.offsetX + e.nativeEvent.srcElement.offsetParent.offsetLeft;
    return (this.props.clickOffsetY =
      e.nativeEvent.offsetY + e.nativeEvent.srcElement.offsetParent.offsetTop);
  },

  handleInitDrag(e, d) {
    if (this.state.preventDrag) {
      return;
    } // not too happy about this one

    const dx = e.clientX - this.props.clickOffsetX + window.scrollX;
    const dy = e.clientY - this.props.clickOffsetY + window.scrollY;

    return this.setState({ dragged: true, dx, dy });
  },

  // Expects size hash with:
  //   w: [viewer width]
  //   h: [viewer height]
  //   scale:
  //     horizontal: [horiz scaling of image to fit within above vals]
  //     vertical:   [vert scaling of image..]
  onViewerResize(size) {
    this.setState({
      viewerSize: size
    });
    return this.updatePosition();
  },

  updatePosition() {
    // HANDLE DIFFERENT TOOLS
    let x, y;
    const { toolName } = this.props.subject.data;
    switch (toolName) {
      case "pointTool":
        x = this.props.subject.data.x + 40;
        y = this.props.subject.data.y + 40; // TODO: don't hard-wire dimensions
        break;
      case "rectangleTool":
        ({ x } = this.props.subject.data);
        y = this.props.subject.data.y + this.props.subject.data.height;
        break;
      case "textRowTool":
        x =
          this.state.viewerSize != null
            ? (this.state.viewerSize.w - 650) / 2
            : 0; // TODO: don't hard-wire dimensions
        y = this.props.subject.data.yLower;
        break;
      default:
        console.log(
          `ERROR: Cannot update position on unknown transcription tool ${toolName}!`
        );
    }

    if (this.state.viewerSize != null && !this.state.dragged) {
      return this.setState({
        dx: x * this.state.viewerSize.scale.horizontal,
        dy: y * this.state.viewerSize.scale.vertical
      });
    }
  },

  commitAnnotation() {
    return this.props.onComplete(this.state.annotation);
  },

  handleChange(e) {
    this.state.annotation.value = e.target.value;
    return this.forceUpdate();
  },

  handleKeyPress(e) {
    if ([13].indexOf(e.keyCode) >= 0) {
      // ENTER:
      this.commitAnnotation();
      return e.preventDefault();
    }
  },

  render() {
    let toolType;
    if (this.props.viewerSize == null || this.props.subject == null) {
      return null;
    }

    // If user has set a custom position, position based on that:
    const style = {
      left: this.state.dx,
      top: this.state.dy
    };

    const val =
      (this.state.annotation != null
        ? this.state.annotation.value
        : undefined) != null
        ? this.state.annotation != null
          ? this.state.annotation.value
          : undefined
        : "";

    if (this.props.subject.type === "item_location") {
      toolType = "testComponent";
    } else {
      toolType = this.props.task.tool_options.tool_type;
    }

    if (inputComponents[toolType] == null) {
      console.log(`ERROR: Field type, ${toolType}, does not exist!`);
      return null;
    }

    const InputComponent = inputComponents[toolType];

    return (
      <Draggable
        onStart={this.handleInitStart}
        onDrag={this.handleInitDrag}
        onEnd={this.handleInitRelease}
        ref="inputWrapper0"
      >
        <div className="transcribe-tool" style={style}>
          <InputComponent
            key={this.props.task.key}
            val={
              (this.state.annotation != null
                ? this.state.annotation.value
                : undefined) != null
                ? this.state.annotation != null
                  ? this.state.annotation.value
                  : undefined
                : ""
            }
            instruction={this.props.task.instruction}
            handleChange={this.handleChange}
            onKeyPress={this.handleKeyPress}
            commitAnnotation={this.commitAnnotation}
          />
        </div>
      </Draggable>
    );
  }
});

module.exports = TextTool;

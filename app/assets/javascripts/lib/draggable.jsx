/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const ReactDOM = require("react-dom");
const PropTypes = require('prop-types');

const createReactClass = require("create-react-class");
module.exports = createReactClass({
  displayName: "Draggable",

  _previousEventCoords: null,

  getDefaultProps() {
    return { disableDragIn: ["INPUT", "TEXTAREA", "A", "BUTTON"] };
  },

  getInitialState() {
    return {
      x: this.props.x, // ? 0
      y: this.props.y, //? 0
      dragged: false
    };
  },

  componentWillReceiveProps(new_props) {
    if (!this.state.dragged) {
      this.setState({
        x: new_props.x,
        y: new_props.y
      });
    }
  },

  propTypes: {
    // children: PropTypes.component.isRequired
    onStart: PropTypes.oneOfType([
      PropTypes.func,
      PropTypes.bool
    ]),
    onDrag: PropTypes.func,
    onEnd: PropTypes.func,
    disabled: PropTypes.bool
  },

  render() {
    // NOTE: This won't actually render any new DOM nodes,
    // it just attaches a `mousedown` listener to its child.
    if (this.props.disabled) {
      return this.props.children;
    } else {
      const style = {
        left: this.state.x,
        top: this.state.y
      };
      return React.cloneElement(this.props.children, {
        className: `${
          this.props.children.props != null
            ? this.props.children.props.className
            : undefined
        } draggable`,
        onMouseDown: this.handleStart,
        style
      });
    }
  },

  _rememberCoords(e) {
    return (this._previousEventCoords = {
      x: e.pageX,
      y: e.pageY
    });
  },

  handleStart(e) {
    if (e.button !== 0) {
      return;
    }
    if (this.props.disableDragIn.indexOf(e.target.nodeName) >= 0) {
      return;
    }
    if ($(e.target).parents(this.props.disableDragIn.join(",")).length > 0) {
      return;
    }

    const $el = $(ReactDOM.findDOMNode(this));
    const pos = $el.position();
    const offset = $el.offset();
    const parent_left = offset.left - pos.left;
    const parent_top = offset.top - pos.top;

    this.setState({
      dragging: true,
      rel: {
        x: e.pageX - pos.left,
        y: e.pageY - pos.top,
        min_x: -parent_left,
        min_y: -parent_top,
        max_x: $(document).width() - $el.width() - parent_left,
        max_y: $(document).height() - $el.height() - parent_top
      }
    });

    this._rememberCoords(e);

    // Prefix with this class to switch from `cursor:grab` to `cursor:grabbing`.
    document.body.classList.add("dragging");
    document.addEventListener("mousemove", this.handleDrag);
    document.addEventListener("mouseup", this.handleEnd);

    // If there's no `onStart`, `onDrag` will be called on start.
    const startHandler =
      this.props.onStart != null ? this.props.onStart : this.handleDrag;
    if (startHandler) {
      // You can set it to `false` if you don't want anything to fire.
      return startHandler(e);
    }
  },

  handleDrag(e) {
    // prevent dragging on input and textarea elements
    if (e.target.nodeName === "INPUT" || e.target.nodeName === "TEXTAREA") {
      return;
    }
    if (!this.state.dragging) {
      return;
    }

    let x = e.pageX - this.state.rel.x;
    let y = e.pageY - this.state.rel.y;

    // ensure element is in bounds of document
    if (x < this.state.rel.min_x) {
      x = this.state.rel.min_x;
    }
    if (y < this.state.rel.min_y) {
      y = this.state.rel.min_y;
    }
    if (x > this.state.rel.max_x) {
      x = this.state.rel.max_x;
    }
    if (y > this.state.rel.max_y) {
      y = this.state.rel.max_y;
    }

    this.setState({
      x,
      y,
      dragged: true
    });

    const d = {
      x: e.pageX - this._previousEventCoords.x,
      y: e.pageY - this._previousEventCoords.y
    };

    if (typeof this.props.onDrag === "function") {
      this.props.onDrag({ x, y }, d);
    }

    return this._rememberCoords(e);
  },

  handleEnd(e) {
    this.setState({
      dragging: false
    });

    document.removeEventListener("mousemove", this.handleDrag);
    document.removeEventListener("mouseup", this.handleEnd);

    if (typeof this.props.onEnd === "function") {
      this.props.onEnd(e);
    }

    this._previousEventCoords = null;

    return document.body.classList.remove("dragging");
  }
});

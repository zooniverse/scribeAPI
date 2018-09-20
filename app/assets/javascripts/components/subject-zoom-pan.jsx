import React from "react";

const ZOOM_STEP = 0.35; // Amount to zoom by
const ZOOM_MAX = 3;
const ZOOM_MIN = 1;

const PAN_STEP = 0.1; // Amount to pan by
const PAN_MIN_X = 0; //
const PAN_MAX_X = 0.7; // Max allowed val for x
const PAN_MIN_Y = 0;
const PAN_MAX_Y = 0.7; // Max allowed val for y

// Default interpretation of "pan up" is to effectively move the viewport, rather than move the image
// The following inverts this, moving the image upward instead
const INVERT_PAN = false;

export default class SubjectZoomPan extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      zoom: {
        level: 1,
        x: 0,
        y: 0
      }
    };
  }

  componentDidMount() {
    window.addEventListener("keydown", this._handleZoomKeys.bind(this));
  }

  componentWillUnmount() {
    window.removeEventListener("keydown", this._handleZoomKeys.bind(this));
  }

  // Zoom given amount (1 or -1)
  zoom(dir) {
    const { zoom } = this.state;
    zoom.level += ZOOM_STEP * dir;
    if (dir < 0) {
      zoom.level = Math.max(ZOOM_MIN, zoom.level);
    }
    if (dir > 0) {
      zoom.level = Math.min(ZOOM_MAX, zoom.level);
    }
    this._changed(zoom);
  }

  // Pan in given direction
  pan(dir) {
    const { zoom } = this.state;

    if (dir === "up" || dir === "down") {
      zoom.y = this._computeNewPanValue(dir);
    } else {
      zoom.x = this._computeNewPanValue(dir);
    }

    zoom.x = Math.min(PAN_MAX_X, zoom.x);
    zoom.x = Math.max(PAN_MIN_X, zoom.x);
    zoom.y = Math.min(PAN_MAX_Y, zoom.y);
    zoom.y = Math.max(PAN_MIN_Y, zoom.y);

    this._changed(zoom);
  }

  // Reset zoom & pan state:
  reset() {
    this._changed({
      level: 1,
      x: 0,
      y: 0
    });
  }

  // Returns true if the given zoom amount (1 or -1) is possible
  canZoom(dir) {
    if (dir === 1) {
      return this.state.zoom.level < ZOOM_MAX;
    } else {
      return this.state.zoom.level > ZOOM_MIN;
    }
  }

  // Returns true if the given pan direction is possible
  canPan(dir) {
    let val;
    if (dir === "up" || dir === "down") {
      val = this._computeNewPanValue(dir);
      return val >= PAN_MIN_Y && val <= PAN_MAX_Y;
    } else if (dir === "right" || dir === "left") {
      val = this._computeNewPanValue(dir);
      return val >= PAN_MIN_X && val <= PAN_MAX_X;
    }
  }

  // Register given zoom/pan state and notify parent
  _changed(zoom) {
    this.setState({ zoom }, () => {
      const w = this.props.subject.width / this.state.zoom.level;
      const h = this.props.subject.height / this.state.zoom.level;
      const x = this.props.subject.width * this.state.zoom.x;
      const y = this.props.subject.height * this.state.zoom.y;

      if (typeof this.props.onChange === "function") {
        this.props.onChange([x, y, w, h])
      }
    });
  }

  // Compute next value for either x or y given pan direction
  _computeNewPanValue(dir) {
    const { zoom } = this.state;
    const inv = INVERT_PAN ? -1 : 1;

    if (dir === "right") {
      return zoom.x + PAN_STEP * inv;
    } else if (dir === "left") {
      return zoom.x - PAN_STEP * inv;
    } else if (dir === "up") {
      return zoom.y - PAN_STEP * inv;
    } else if (dir === "down") {
      return zoom.y + PAN_STEP * inv;
    }
  }

  // Handle keydowns for zoom (WASD) and zoom (-+)
  _handleZoomKeys(e) {
    switch (e.which) {
      case 87:
        this.pan("up"); // w
        break;
      case 83:
        this.pan("down"); // s
        break;
      case 65:
        this.pan("left"); // a
        break;
      case 68:
        this.pan("right"); // d
        break;
      case 61:
      case 187:
        this.zoom(1); // +
        break;
      case 173:
      case 189:
        this.zoom(-1); // -
        break;
    }
  }

  render() {
    return (
      <div className="subject-zoom-pan">
        <button className={`zoom out ${!this.canZoom(-1) ? "disabled" : ''}`}
          title="zoom out"
          onClick={() => this.zoom(-1)} />
        <button className={`zoom in ${!this.canZoom(1) ? "disabled" : ''}`}
          title="zoom in"
          onClick={() => this.zoom(1)} />
        <button className={`pan up ${!this.canPan("up") ? "disabled" : ''}`}
          title="pan up"
          onClick={() => this.pan("up")} />
        <button className={`pan right ${!this.canPan("right") ? "disabled" : ''}`}
          title="pan right"
          onClick={() => this.pan("right")} />
        <button className={`pan left ${!this.canPan("left") ? "disabled" : ''}`}
          title="pan left"
          onClick={() => this.pan("left")} />
        <button className={`pan down ${!this.canPan("down") ? "disabled" : ''}`}
          title="pan down"
          onClick={() => this.pan("down")} />
        <button className="reset" onClick={() => this.reset()}>
          reset
        </button>
      </div>
    );
  }
}

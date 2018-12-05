import React from 'react'
import { BehaviorSubject } from 'rxjs'
import { debounceTime, distinctUntilChanged } from 'rxjs/operators'

/**
 * Amount to zoom by
 */
const ZOOM_STEP = 0.35
const ZOOM_MAX = 3
const ZOOM_MIN = 0.6

/**
 * Amount to pan by
 */
const PAN_STEP = 0.1
const PAN_MIN_X = 0
const PAN_MIN_Y = 0

/**
 * Default interpretation of "pan up" is to effectively move the viewport, rather than move the image
 * The following inverts this, moving the image upward instead
 */
const INVERT_PAN = false

export default class SubjectZoomPan extends React.Component {

  constructor(props) {
    super(props)
    this.state = {
      scrollY: 0,
      maxScrollY: 1000,
      zoom: {
        level: 1,
        x: 0,
        y: 0
      }
    }
    this._handleZoomKeys = this._handleZoomKeys.bind(this)
    this._handleScrollOffset = this._handleScrollOffset.bind(this)
  }

  componentDidMount() {
    window.addEventListener('keydown', this._handleZoomKeys)
    window.addEventListener('scroll', this._handleScrollOffset)

    const scrollY = window.scrollY
    const $subjectViewerSvg = $('.subject-viewer-svg')
    const maxScrollY = 20 + $subjectViewerSvg.offset().top + $subjectViewerSvg.height() - window.innerHeight
    this.setState({ scrollY, maxScrollY })

    this.scrollOffset = new BehaviorSubject(scrollY)
    this.scrollOffset.pipe(
      debounceTime(150),
      distinctUntilChanged()
    ).subscribe(scrollY => {
      this.setState({ scrollY })
    })
  }

  componentWillUnmount() {
    window.removeEventListener('keydown', this._handleZoomKeys)
    window.removeEventListener('scroll', this._handleScrollOffset)
    this.scrollOffset.complete()
  }

  /**
   * Zoom given amount (1 or -1)
   */
  zoom(dir) {
    const { zoom } = this.state
    zoom.level += ZOOM_STEP * dir
    if (dir < 0) {
      zoom.level = Math.max(ZOOM_MIN, zoom.level)
      if (zoom.level < 1) {
        this.scrollTop(0, 1000)
      }
    }
    if (dir > 0) {
      zoom.level = Math.min(ZOOM_MAX, zoom.level)
    }
    this._changed(zoom)
  }

  /**
   * Pan in given direction
   * @param {"down" | "up" | "left" | "right"} dir 
   */
  pan(dir) {
    const { zoom } = this.state

    if (dir === 'down' && this.state.scrollY < this.state.maxScrollY) {
      this.panWindow(1)
      return
    } else if (dir === 'up' && this.state.scrollY > 0) {
      this.panWindow(-1)
      return
    } else if (dir === 'up' || dir === 'down') {
      zoom.y = this._computeNewPanValue(dir)
    } else {
      zoom.x = this._computeNewPanValue(dir)
    }

    const maxPan = this.getMaxPan(zoom)
    zoom.x = Math.min(maxPan, zoom.x)
    zoom.x = Math.max(PAN_MIN_X, zoom.x)
    zoom.y = Math.min(maxPan, zoom.y)
    zoom.y = Math.max(PAN_MIN_Y, zoom.y)

    this._changed(zoom)
  }

  /**
   * Pan the window, this is done instead of panning the view box.
   * @param {1 | -1} direction Pan up or down
   */
  panWindow(direction) {
    const scrollTop = Math.min(
      this.state.maxScrollY + 5,
      window.scrollY + direction * (PAN_STEP * this.props.subject.height))
    this.scrollTop(scrollTop)
  }

  scrollTop(scrollTop, time = 200) {
    $('html, body')
      .stop()
      .animate({
        scrollTop
      }, time)
  }

  /**
   * Limits the panning to the displayed content.
   */
  getMaxPan(zoom) {
    return Math.max(0, (zoom.level - 1) / zoom.level)
  }

  /**
   * Reset zoom & pan state
   */
  reset() {
    this._changed({
      level: 1,
      x: 0,
      y: 0
    })
  }

  /**
   * Returns true if the given zoom amount (1 or -1) is possible
   */
  canZoom(dir) {
    if (dir === 1) {
      return this.state.zoom.level < ZOOM_MAX
    } else {
      return this.state.zoom.level > ZOOM_MIN
    }
  }

  /**
   * Returns true if the given pan direction is possible
   */
  canPan(dir) {
    let val
    const maxPan = this.getMaxPan(this.state.zoom)
    if (dir === 'down' && this.state.scrollY < this.state.maxScrollY) {
      return true
    } else if (dir === 'up' && this.state.scrollY > 0) {
      return true
    } else if (dir === 'up' || dir === 'down') {
      val = this._computeNewPanValue(dir)
      return val >= PAN_MIN_Y && val <= maxPan
    } else if (dir === 'right' || dir === 'left') {
      val = this._computeNewPanValue(dir)
      return val >= PAN_MIN_X && val <= maxPan
    }
  }

  /**
   * Register given zoom/pan state and notify parent
   */
  _changed(zoom) {
    this.setState({ zoom }, () => {
      const w = this.props.subject.width / this.state.zoom.level
      const h = this.props.subject.height / this.state.zoom.level
      const x = this.props.subject.width * this.state.zoom.x
      const y = this.props.subject.height * this.state.zoom.y

      if (typeof this.props.onChange === 'function') {
        this.props.onChange([x, y, w, h])
      }
    })
  }

  /**
   * Compute next value for either x or y given pan direction
   */
  _computeNewPanValue(dir) {
    const { zoom } = this.state
    const inv = INVERT_PAN ? -1 : 1

    if (dir === 'right') {
      return zoom.x + PAN_STEP * inv
    } else if (dir === 'left') {
      return zoom.x - PAN_STEP * inv
    } else if (dir === 'up') {
      return zoom.y - PAN_STEP * inv
    } else if (dir === 'down') {
      return zoom.y + PAN_STEP * inv
    }
  }

  /**
   * Handle keydowns for zoom (WASD) and zoom (-+)
   */
  _handleZoomKeys(e) {
    switch (e.which) {
      case 87:
        this.pan('up') // w
        break
      case 83:
        this.pan('down') // s
        break
      case 65:
        this.pan('left') // a
        break
      case 68:
        this.pan('right') // d
        break
      case 61:
      case 187:
        this.zoom(1) // +
        break
      case 173:
      case 189:
        this.zoom(-1) // -
        break
    }
  }

  _handleScrollOffset() {
    this.scrollOffset.next(window.scrollY)
  }

  render() {
    return (
      <div className="subject-zoom-pan">
        <button className={`zoom out ${!this.canZoom(-1) ? 'disabled' : ''}`}
          title="zoom out"
          onClick={() => this.zoom(-1)} />
        <button className={`zoom in ${!this.canZoom(1) ? 'disabled' : ''}`}
          title="zoom in"
          onClick={() => this.zoom(1)} />
        <button className={`pan up ${!this.canPan('up') ? 'disabled' : ''}`}
          title="pan up"
          onClick={() => this.pan('up')} />
        <button className={`pan right ${!this.canPan('right') ? 'disabled' : ''}`}
          title="pan right"
          onClick={() => this.pan('right')} />
        <button className={`pan left ${!this.canPan('left') ? 'disabled' : ''}`}
          title="pan left"
          onClick={() => this.pan('left')} />
        <button className={`pan down ${!this.canPan('down') ? 'disabled' : ''}`}
          title="pan down"
          onClick={() => this.pan('down')} />
        <button className="reset" onClick={() => this.reset()}>
          reset
        </button>
      </div>
    )
  }
}

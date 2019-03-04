/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import PropTypes from 'prop-types'

import createReactClass from 'create-react-class'
export default createReactClass({
  displayName: 'MouseHandler',

  _previousEventCoords: null,

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
      return this.props.children
    } else {
      return React.cloneElement(this.props.children, {
        className: `${this.props.children.props.className} draggable`,
        onMouseDown: this.handleStart
      })
    }
  },

  _rememberCoords(e) {
    return (this._previousEventCoords = {
      x: e.pageX,
      y: e.pageY
    })
  },

  handleStart(e) {
    if (e.target.nodeName === 'INPUT' || e.target.nodeName === 'TEXTAREA') {
      return false
    }
    if ($(e.target).parents('a').length > 0) {
      return false
    }
    e.preventDefault()

    this._rememberCoords(e)

    // Prefix with this class to switch from `cursor:grab` to `cursor:grabbing`.
    document.body.classList.add('dragging')

    document.addEventListener('mousemove', this.handleDrag)
    document.addEventListener('mouseup', this.handleEnd)

    // If there's no `onStart`, `onDrag` will be called on start.
    const startHandler =
      this.props.onStart != null ? this.props.onStart : this.handleDrag
    if (startHandler) {
      // You can set it to `false` if you don't want anything to fire.
      return startHandler(e)
    }
  },

  handleDrag(e) {
    const d = {
      x: e.pageX - this._previousEventCoords.x,
      y: e.pageY - this._previousEventCoords.y
    }

    if (typeof this.props.onDrag === 'function') {
      this.props.onDrag(e, d)
    }

    return this._rememberCoords(e)
  },

  handleEnd(e) {
    document.removeEventListener('mousemove', this.handleDrag)
    document.removeEventListener('mouseup', this.handleEnd)

    if (typeof this.props.onEnd === 'function') {
      this.props.onEnd(e)
    }

    this._previousEventCoords = null

    return document.body.classList.remove('dragging')
  }
})

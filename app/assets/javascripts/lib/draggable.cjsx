React = require 'react'
cloneWithProps = require 'react/lib/cloneWithProps'

module.exports = React.createClass
  displayName: 'Draggable'

  _previousEventCoords: null

  propTypes:
    children: React.PropTypes.component.isRequired
    onStart: React.PropTypes.oneOfType [
      React.PropTypes.func
      React.PropTypes.bool
    ]
    onDrag: React.PropTypes.func
    onEnd: React.PropTypes.func
    disabled: React.PropTypes.bool

  render: ->
    # NOTE: This won't actually render any new DOM nodes,
    # it just attaches a `mousedown` listener to its child.
    if @props.disabled
      @props.children
    else
      cloneWithProps @props.children,
        className: 'draggable'
        onMouseDown: @handleStart

  _rememberCoords: (e) ->
    @_previousEventCoords =
      x: e.pageX
      y: e.pageY

  handleStart: (e) ->
    e.preventDefault()

    @_rememberCoords e

    # Prefix with this class to switch from `cursor:grab` to `cursor:grabbing`.
    document.body.classList.add 'dragging'

    document.addEventListener 'mousemove', @handleDrag
    document.addEventListener 'mouseup', @handleEnd

    # If there's no `onStart`, `onDrag` will be called on start.
    startHandler = @props.onStart ? @handleDrag
    if startHandler # You can set it to `false` if you don't want anything to fire.
      startHandler e

  handleDrag: (e) ->
    d =
      x: e.pageX - @_previousEventCoords.x
      y: e.pageY - @_previousEventCoords.y

    @props.onDrag? e, d

    @_rememberCoords e

  handleEnd: (e) ->
    document.removeEventListener 'mousemove', @handleDrag
    document.removeEventListener 'mouseup', @handleEnd

    @props.onEnd? e

    @_previousEventCoords = null

    document.body.classList.remove 'dragging'

# @cjsx React.DOM

React = require 'react'
cloneWithProps = require 'react/lib/cloneWithProps'

module.exports = React.createClass
  displayName: 'Draggable'

  propTypes:
    children: React.PropTypes.component.isRequired
    onStart: React.PropTypes.oneOfType [
      React.PropTypes.func
      React.PropTypes.bool
    ]
    onDrag: React.PropTypes.func
    onEnd: React.PropTypes.func

  render: ->
    # NOTE: This won't actually render any new DOM nodes,
    # it just attaches a `mousedown` listener to its child.
    cloneWithProps @props.children,
      className: 'draggable'
      onMouseDown: @handleStart

  handleStart: (e) ->
    # console.log 'DRAGGABLE: handleStart()'
    e.preventDefault()
    document.addEventListener 'mousemove', @handleDrag
    document.addEventListener 'mouseup', @handleEnd

    # If there's not `onStart`, `onDrag` will be called on start.
    startHandler = @props.onStart ? @handleDrag
    if startHandler # You can set to `false` if you don't want anything to fire.
      startHandler e

    # Prefix with this class to switch from `cursor:grab` to `cursor:grabbing`.
    document.body.classList.add 'dragging'

  handleDrag: (e) ->
    # console.log 'DRAGGABLE: handleDrag()'
    @props.onDrag? e

  handleEnd: (e) ->
    # console.log 'DRAGGABLE: handleEnd()'
    document.removeEventListener 'mousemove', @handleDrag
    document.removeEventListener 'mouseup', @handleEnd

    @props.onEnd? e

    document.body.classList.remove 'dragging'

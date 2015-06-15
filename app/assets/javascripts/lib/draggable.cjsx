React = require 'react'
cloneWithProps = require 'react/lib/cloneWithProps'

module.exports = React.createClass
  displayName: 'Draggable'

  _previousEventCoords: null

  getInitialState: ->
    # console.log "Draggable[#{@props.inst}]#getInitialState: ", @props.x, @props.y
    x: @props.x # ? 0
    y: @props.y #? 0

  componentWillReceiveProps: ->
    # console.log 'DRAGGABLE::componentWillReceiveProps(), props =', @props
    @setState
      x: @props.x
      y: @props.y
  # shouldComponentUpdate: ->
    # console.log "Draggable#shouldComponentUpdate", @props.x

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
      style =
        left: @state.x
        top: @state.y
      # console.log "Draggable[#{@props.inst}] render: ", style
      cloneWithProps @props.children,
        className: 'draggable'
        onMouseDown: @handleStart
        style: style

  _rememberCoords: (e) ->
    # console.log "remCoord event", e
    # console.log "e.pageX", e.pageX
    @_previousEventCoords =
      x: e.pageX
      y: e.pageY

  handleStart: (e) ->

    return if e.button != 0
    # console.log "Draggable: handleStart"
    return false if e.target.nodeName is "INPUT" or e.target.nodeName is "TEXTAREA"
    return false if $(e.target).parents('a').length > 0
    # console.log "Draggable: handleStart ... continuing"
    e.preventDefault()
    e.stopPropagation()

    # pos = $(this.getDOMNode()).offset()
    pos = $(this.getDOMNode()).position()

    # console.log "Draggable#handleStart: ", e.pageX, pos.left
    @setState
      dragging: true,
      rel:
        x: e.pageX - pos.left,
        y: e.pageY - pos.top

    @_rememberCoords e
    # console.log "previous coords", @_previousEventCoords

    # Prefix with this class to switch from `cursor:grab` to `cursor:grabbing`.
    document.body.classList.add 'dragging'
    document.addEventListener 'mousemove', @handleDrag
    document.addEventListener 'mouseup', @handleEnd

    # If there's no `onStart`, `onDrag` will be called on start.
    startHandler = @props.onStart ? @handleDrag
    if startHandler # You can set it to `false` if you don't want anything to fire.
      startHandler e

  handleDrag: (e) ->
    # console.log "handleDrag event", e

    return if ! @state.dragging

    x = e.pageX - this.state.rel.x
    y = e.pageY - this.state.rel.y
    @setState
      x: x
      y: y

    d =
      x: e.pageX - @_previousEventCoords.x
      y: e.pageY - @_previousEventCoords.y

    @props.onDrag? {x, y}, d

    @_rememberCoords e

  handleEnd: (e) ->
    @setState
      dragging: false


    document.removeEventListener 'mousemove', @handleDrag
    document.removeEventListener 'mouseup', @handleEnd

    @props.onEnd? e

    @_previousEventCoords = null

    document.body.classList.remove 'dragging'

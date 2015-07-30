React = require 'react'
# cloneWithProps = require 'react/lib/cloneWithProps'

module.exports = React.createClass
  displayName: 'Draggable'

  _previousEventCoords: null

  getDefaultProps: ->
    disableDragIn:    ["INPUT","TEXTAREA","A","BUTTON"]

  getInitialState: ->
    x: @props.x # ? 0
    y: @props.y #? 0
    dragged: false

  componentWillReceiveProps: ->
    if ! @state.dragged
      @setState
        x: @props.x
        y: @props.y

  propTypes:
    # children: React.PropTypes.component.isRequired
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
      React.cloneElement @props.children,
        className: "#{@props.children.props?.className} draggable"
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
    console.log "Draggable: handleStart", @props.disableDragIn.indexOf(e.target.nodeName), e.target.nodeName

    return if @props.disableDragIn.indexOf(e.target.nodeName) >= 0
    return if $(e.target).parents(@props.disableDragIn.join(',')).length > 0
    console.log "handleStart"

    pos = $(this.getDOMNode()).position()

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
    # prevent dragging on input and textarea elements
    return if e.target.nodeName is "INPUT" or e.target.nodeName is "TEXTAREA"
    return if ! @state.dragging

    x = e.pageX - this.state.rel.x
    y = e.pageY - this.state.rel.y
    @setState
      x: x
      y: y
      dragged: true

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

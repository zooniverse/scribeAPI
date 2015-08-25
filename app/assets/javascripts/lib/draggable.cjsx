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

  componentWillReceiveProps: (new_props) ->
    if ! @state.dragged
      @setState
        x: new_props.x
        y: new_props.y

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
    # console.log "Draggable: handleStart", @props.disableDragIn.indexOf(e.target.nodeName), e.target.nodeName

    return if @props.disableDragIn.indexOf(e.target.nodeName) >= 0
    return if $(e.target).parents(@props.disableDragIn.join(',')).length > 0

    $el = $(this.getDOMNode())
    pos = $el.position()
    offset = $el.offset()
    parent_left = offset.left - pos.left
    parent_top = offset.top - pos.top

    @setState
      dragging: true,
      rel:
        x: e.pageX - pos.left,
        y: e.pageY - pos.top
        min_x: -parent_left
        min_y: -parent_top
        max_x: $(document).width() - $el.width() - parent_left
        max_y: $(document).height() - $el.height() - parent_top

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

    # ensure element is in bounds of document
    x = this.state.rel.min_x if x < this.state.rel.min_x
    y = this.state.rel.min_y if y < this.state.rel.min_y
    x = this.state.rel.max_x if x > this.state.rel.max_x
    y = this.state.rel.max_y if y > this.state.rel.max_y

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

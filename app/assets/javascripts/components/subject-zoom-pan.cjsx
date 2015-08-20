React = require 'react'

ZOOM_STEP   = 0.35    # Amount to zoom by 
ZOOM_MAX    = 3
ZOOM_MIN    = 1

PAN_STEP    = 0.10    # Amount to pan by
PAN_MIN_X   = 0       # 
PAN_MAX_X   = 0.7     # Max allowed val for x
PAN_MIN_Y   = 0
PAN_MAX_Y   = 0.7     # Max allowed val for y

# Default interpretation of "pan up" is to effectively move the viewport, rather than move the image
# The following inverts this, moving the image upward instead
INVERT_PAN  = false

module.exports = React.createClass
  displayName: "SubjectZoomPan"

  getInitialState: ->
    zoom:
      level: 1
      x: 0
      y: 0

  componentDidMount: ->
    window.addEventListener "keydown", (e) => @_handleZoomKeys(e)

  # Zoom given amount (1 or -1)
  zoom: (dir) ->
    zoom = @state.zoom
    zoom.level += ZOOM_STEP * dir
    zoom.level = Math.max ZOOM_MIN, zoom.level if dir < 0
    zoom.level = Math.min ZOOM_MAX, zoom.level if dir > 0
    @_changed zoom

  # Pan in given direction
  pan: (dir) ->
    zoom = @state.zoom

    if dir == 'up' || dir == 'down'
      zoom.y = @_computeNewPanValue dir
    else
      zoom.x = @_computeNewPanValue dir

    zoom.x = Math.min PAN_MAX_X, zoom.x
    zoom.x = Math.max PAN_MIN_X, zoom.x
    zoom.y = Math.min PAN_MAX_Y, zoom.y
    zoom.y = Math.max PAN_MIN_Y, zoom.y

    @_changed zoom

  # Reset zoom & pan state:
  reset: ->
    @_changed
      level: 1
      x: 0
      y: 0

  # Returns true if the given zoom amount (1 or -1) is possible
  canZoom: (dir) ->
    if dir == 1
      @state.zoom.level < ZOOM_MAX
    else
      @state.zoom.level > ZOOM_MIN

  # Returns true if the given pan direction is possible
  canPan: (dir) ->
    if dir == 'up' || dir == 'down'
      val = @_computeNewPanValue(dir)
      val >= PAN_MIN_Y && val <= PAN_MAX_Y

    else if dir == 'right' || dir == 'left'
      val = @_computeNewPanValue(dir)
      val >= PAN_MIN_X && val <= PAN_MAX_X

  # Register given zoom/pan state and notify parent
  _changed: (zoom) ->
    @setState zoom: zoom, () =>
      w = @props.subject.width / @state.zoom.level
      h = @props.subject.height / @state.zoom.level
      x = @props.subject.width * @state.zoom.x
      y = @props.subject.height * @state.zoom.y
      @props.onChange? [ x, y, w, h ]

  # Compute next value for either x or y given pan direction
  _computeNewPanValue: (dir) ->
    zoom = @state.zoom
    inv = if INVERT_PAN then -1 else 1

    if dir == 'right'
      zoom.x + PAN_STEP * inv

    else if dir == 'left'
      zoom.x - PAN_STEP * inv

    else if dir == 'up'
      zoom.y - PAN_STEP * inv

    else if dir == 'down'
      zoom.y + PAN_STEP * inv

  # Handle keydowns for zoom (WASD) and zoom (-+)
  _handleZoomKeys: (e) ->
    @pan 'up' if e.which == 87 # w
    @pan 'down' if e.which == 83 # s
    @pan 'left' if e.which == 65 # a
    @pan 'right' if e.which == 68 # d

    @zoom 1 if e.which == 187 # 61 # +
    @zoom -1 if e.which == 189 # 173 # -

  render: ->
    <div className="subject-zoom-pan">
      <button className="zoom out" onClick={() => @zoom -1} disabled={if ! @canZoom(-1) then 'disabled'}>-</button>
      <button className="zoom in" onClick={() => @zoom 1} disabled={if ! @canZoom(1) then 'disabled'}>+</button>
      <button className="pan up" onClick={() => @pan 'up'} disabled={if ! @canPan('up') then 'disabled'}>^</button>
      <button className="pan right" onClick={() => @pan 'right'} disabled={if ! @canPan('right') then 'disabled'}>&gt;</button>
      <button className="pan left" onClick={() => @pan 'left'} disabled={if ! @canPan('left') then 'disabled'}>&lt;</button>
      <button className="pan down" onClick={() => @pan 'down'} disabled={if ! @canPan('down') then 'disabled'}>V</button>
      <button className="reset" onClick={@reset}>reset</button>
    </div>

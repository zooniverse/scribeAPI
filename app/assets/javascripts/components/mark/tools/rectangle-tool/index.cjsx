React           = require 'react'
Draggable       = require 'lib/draggable'
DragHandle      = require './drag-handle'
DeleteButton    = require 'components/buttons/delete-mark'
MarkButtonMixin = require 'lib/mark-button-mixin'

MINIMUM_SIZE = 15
DELETE_BUTTON_ANGLE = 45
DELETE_BUTTON_DISTANCE_X = 12
DELETE_BUTTON_DISTANCE_Y = 0
DEBUG = false

module.exports = React.createClass
  displayName: 'RectangleTool'

  mixins: [MarkButtonMixin]

  propTypes:
    # key:  React.PropTypes.number.isRequired
    mark: React.PropTypes.object.isRequired

  initCoords: null

  statics:
    defaultValues: ({x, y}) ->
      x: x
      y: y
      width: 0
      height: 0

    initStart: ({x,y}, mark) ->
      @initCoords = {x,y}
      {x,y}

    initMove: (cursor, mark) ->
      if cursor.x > @initCoords.x
        width = cursor.x - mark.x
        x = mark.x
      else
        width = @initCoords.x - cursor.x
        x = cursor.x

      if cursor.y > @initCoords.y
        height = cursor.y - mark.y
        y = mark.y
      else
        height = @initCoords.y - cursor.y
        y = cursor.y

      {x, y, width, height}

    initValid: (mark) ->
      mark.width > MINIMUM_SIZE and mark.height > MINIMUM_SIZE

    # This callback is called on mouseup to override mark properties (e.g. if too small)
    initRelease: (coords, mark, e) ->
      mark.width = Math.max mark.width, MINIMUM_SIZE
      mark.height = Math.max mark.height, MINIMUM_SIZE
      mark

  getInitialState: ->
    mark = @props.mark
    unless mark.status?
      mark.status = 'mark'
    mark: mark
    # set up the state in order to caluclate the polyline as rectangle
    x1 = @props.mark.x
    x2 = x1 + @props.mark.width
    y1 = @props.mark.y
    y2 = y1 + @props.mark.height

    pointsHash: @createRectangleObjects(x1, x2, y1, y2)

    buttonDisabled: false
    lockTool: false

  componentWillReceiveProps:(newProps)->
    x1 = newProps.mark.x
    x2 = x1 + newProps.mark.width
    y1 = newProps.mark.y
    y2 = y1 + newProps.mark.height

    @setState pointsHash: @createRectangleObjects(x1, x2, y1, y2)

  createRectangleObjects: (x1 , x2, y1, y2) ->
    if x1 < x2
      LX = x1
      HX = x2
    else
      LX = x2
      HX = x1

    if y1 < y2
      LY = y1
      HY = y2
    else
      LY = y2
      HY = y1

    # PB: L and H seem to denote Low and High values of x & y, so:
    # LL: upper left
    # HL: upper right
    # HH: lower right
    # LH: lower left
    pointsHash = {
      handleLLDrag: [LX, LY],
      handleHLDrag: [HX, LY],
      handleHHDrag: [HX, HY],
      handleLHDrag: [LX, HY]
    }

  handleMainDrag: (e, d) ->
    return if @state.locked
    return if @props.disabled
    @props.mark.x += d.x / @props.xScale
    @props.mark.y += d.y / @props.yScale
    @assertBounds()
    @props.onChange e

  dragFilter: (key) ->
    if key == "handleLLDrag"
      return @handleLLDrag
    if key == "handleLHDrag"
      return @handleLHDrag
    if key == "handleHLDrag"
      return @handleHLDrag
    if key == "handleHHDrag"
      return @handleHHDrag

  handleLLDrag: (e, d) ->
    @props.mark.x += d.x / @props.xScale
    @props.mark.width -= d.x / @props.xScale
    @props.mark.y += d.y / @props.yScale
    @props.mark.height -= d.y / @props.yScale
    @props.onChange e

  handleLHDrag: (e, d) ->
    @props.mark.x += d.x / @props.xScale
    @props.mark.width -= d.x / @props.xScale
    @props.mark.height += d.y / @props.yScale
    @props.onChange e

  handleHLDrag: (e, d) ->
    @props.mark.width += d.x / @props.xScale
    @props.mark.y += d.y / @props.yScale
    @props.mark.height -= d.y / @props.yScale
    @props.onChange e

  handleHHDrag: (e, d) ->
    @props.mark.width += d.x / @props.xScale
    @props.mark.height += d.y / @props.yScale
    @props.onChange e


  assertBounds: ->
    @props.mark.x = Math.min @props.sizeRect.props.width - @props.mark.width, @props.mark.x
    @props.mark.y = Math.min @props.sizeRect.props.height - @props.mark.height, @props.mark.y

    @props.mark.x = Math.max 0, @props.mark.x
    @props.mark.y = Math.max 0, @props.mark.y

    @props.mark.width = Math.max @props.mark.width, MINIMUM_SIZE
    @props.mark.height = Math.max @props.mark.height, MINIMUM_SIZE

  validVert: (y,h) ->
    y >= 0 && y + h <= @props.sizeRect.props.height

  validHoriz: (x,w) ->
    x >= 0 && x + w <= @props.sizeRect.props.width

  getDeleteButtonPosition: ()->
    points = @state.pointsHash["handleHLDrag"]
    x = points[0] + DELETE_BUTTON_DISTANCE_X / @props.xScale
    y = points[1] + DELETE_BUTTON_DISTANCE_Y / @props.yScale
    x = Math.min x, @props.sizeRect.props.width - 15 / @props.xScale
    y = Math.max y, 15 / @props.yScale
    {x, y}

  getMarkButtonPosition: ()->
    points = @state.pointsHash["handleHHDrag"]
    x: Math.min points[0], @props.sizeRect.props.width - 40 / @props.xScale
    y: Math.min points[1] + 20 / @props.yScale, @props.sizeRect.props.height - 15 / @props.yScale

  handleMouseDown: ->
    @props.onSelect @props.mark

  normalizeMark: ->
    if @props.mark.width < 0
      @props.mark.x += @props.mark.width
      @props.mark.width *= -1

    if @props.mark.height < 0
      @props.mark.y += @props.mark.height
      @props.mark.height *= -1

    @props.onChange()

  render: ->
    classes = []
    classes.push 'transcribable' if @props.isTranscribable
    classes.push 'interim' if @props.interim
    classes.push if @props.disabled then 'committed' else 'uncommitted'
    classes.push "tanscribing" if @checkLocation()

    x1 = @props.mark.x
    width = @props.mark.width
    x2 = x1 + width
    y1 = @props.mark.y
    height = @props.mark.height
    y2 = y1 + height

    scale = (@props.xScale + @props.yScale) / 2

    points = [
      [x1, y1].join ','
      [x2, y1].join ','
      [x2, y2].join ','
      [x1, y2].join ','
      [x1, y1].join ','
    ].join '\n'

    <g
      tool={this}
      onMouseDown={@props.onSelect}
      title={@props.mark.label}
    >
      <g
        className="rectangle-tool#{if @props.disabled then ' locked' else ''}"
      >

        <Draggable onDrag = {@handleMainDrag} >
          <g
            className="tool-shape #{classes.join ' '}"
            key={points}
            dangerouslySetInnerHTML={
              __html: "
                <filter id=\"dropShadow\">
                  <feGaussianBlur in=\"SourceAlpha\" stdDeviation=\"3\" />
                  <feOffset dx=\"2\" dy=\"4\" />
                  <feMerge>
                    <feMergeNode />
                    <feMergeNode in=\"SourceGraphic\" />
                  </feMerge>
                </filter>

                <polyline
                  #{if @props.mark.color? then "stroke=\"#{@props.mark.color}\""}
                  points=\"#{points}\"
                  filter=\"#{if @props.selected then 'url(#dropShadow)' else 'none'}\"
                />
              "
            }
          />

        </Draggable>

        { if @props.selected
            <DeleteButton onClick={@props.onDestroy} scale={scale} x={@getDeleteButtonPosition(@state.pointsHash).x} y={@getDeleteButtonPosition(@state.pointsHash).y}/>
        }

        {
          if @props.selected && not @props.disabled
            <g>
              {
                for key, value of @state.pointsHash
                  <DragHandle key={key} tool={this} x={value[0]} y={value[1]} onDrag={@dragFilter(key)} onEnd={@normalizeMark} />
              }
            </g>
        }

        { # REQUIRES MARK-BUTTON-MIXIN
          if @props.selected or @state.markStatus is 'transcribe-enabled'
            @renderMarkButton() if @props.isTranscribable
        }

      </g>

    </g>

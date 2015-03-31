React = require 'react'
EllipseTool = require './ellipse'
DrawingToolRoot = require './root'
DragHandle = require './drag-handle'
Draggable = require '../../lib/draggable'
DeleteButton = require './delete-button'

MINIMUM_RADIUS = 5
GUIDE_WIDTH = 1
GUIDE_DASH = [4, 4]
DELETE_BUTTON_ANGLE = 45

module.exports = React.createClass
  displayName: 'EllipseTool'

  statics:
    defaultValues: ({x, y}) ->
      x: x
      y: y
      r: 0
      angle: 0

    initMove: ({x, y}, mark) ->
      distance = @getDistance mark.x, mark.y, x, y
      angle = @getAngle mark.x, mark.y, x, y
      r: distance
      angle: angle

    initValid: (mark) ->
      mark.r > MINIMUM_RADIUS

    getDistance: (x1, y1, x2, y2) ->
      aSquared = Math.pow x2 - x1, 2
      bSquared = Math.pow y2 - y1, 2
      Math.sqrt aSquared + bSquared

    getAngle: (x1, y1, x2, y2) ->
      deltaX = x2 - x1
      deltaY = y2 - y1
      Math.atan2(deltaY, deltaX) * (-180 / Math.PI)

  getDeletePosition: ->
    theta = (DELETE_BUTTON_ANGLE - @props.mark.angle) * (Math.PI / 180)
    x: @props.mark.r * Math.cos theta
    y: -1 * @props.mark.r * Math.sin theta

  render: ->
    positionAndRotate = "
      translate(#{@props.mark.x}, #{@props.mark.y})
      rotate(#{-1 * @props.mark.angle})
    "

    deletePosition = @getDeletePosition()

    <DrawingToolRoot tool={this} transform={positionAndRotate}>
      {if @props.selected
        <line x1="0" y1="0" x2={@props.mark.r} y2="0" strokeWidth={GUIDE_WIDTH / ((@props.scale.horizontal + @props.scale.vertical) / 2)} strokeDasharray={GUIDE_DASH} />}

      <Draggable onDrag={@handleMainDrag} disabled={@props.disabled}>
        <ellipse rx={@props.mark.r} ry={@props.mark.r} />
      </Draggable>

      {if @props.selected
        <g>
          <DeleteButton tool={this} x={deletePosition.x} y={deletePosition.y} rotate={@props.mark.angle} />
          <DragHandle onDrag={@handleRadiusHandleDrag} x={@props.mark.r} y={0} scale={@props.scale} />
        </g>}
    </DrawingToolRoot>

  handleMainDrag: (e, d) ->
    @props.mark.x += d.x / @props.scale.horizontal
    @props.mark.y += d.y / @props.scale.vertical
    @props.onChange e

  handleRadiusHandleDrag: (e, d) ->
    {x, y} = @props.getEventOffset e
    r = @constructor.getDistance @props.mark.x, @props.mark.y , x, y
    angle = @constructor.getAngle @props.mark.x, @props.mark.y , x, y
    @props.mark.r = r
    @props.mark.angle = angle
    @props.onChange e

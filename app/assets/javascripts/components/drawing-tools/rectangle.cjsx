React = require 'react'
DrawingToolRoot = require './root'
DragHandle = require './drag-handle'
Draggable = require '../../lib/draggable'
DeleteButton = require './delete-button'

MINIMUM_SIZE = 5
DELETE_BUTTON_DISTANCE = 9 / 10

module.exports = React.createClass
  displayName: 'RectangleTool'

  statics:
    initCoords: null

    defaultValues: ({x, y}) ->
      x: x
      y: y
      width: 0
      height: 0

    initStart: ({x, y}, mark) ->
      @initCoords = {x, y}
      {x, y}

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

  initCoords: null

  render: ->
    {x, y, width, height} = @props.mark

    points = [
      [x, y].join ','
      [x + width, y].join ','
      [x + width, y + height].join ','
      [x, y + height].join ','
      [x, y].join ','
    ].join '\n'

    <DrawingToolRoot tool={this}>
      <Draggable onDrag={@handleMainDrag} disabled={@props.disabled}>
        <polyline points={points} />
      </Draggable>

      {if @props.selected
        <g>
          <DeleteButton tool={this} x={x + (width * DELETE_BUTTON_DISTANCE)} y={y} />

          <DragHandle x={x} y={y} scale={@props.scale} onDrag={@handleTopLeftDrag} onEnd={@normalizeMark} />
          <DragHandle x={x + width} y={y} scale={@props.scale} onDrag={@handleTopRightDrag} onEnd={@normalizeMark} />
          <DragHandle x={x +  width} y={y + height} scale={@props.scale} onDrag={@handleBottomRightDrag} onEnd={@normalizeMark} />
          <DragHandle x={x} y={y + height} scale={@props.scale} onDrag={@handleBottomLeftDrag} onEnd={@normalizeMark} />
        </g>}
    </DrawingToolRoot>

  handleMainDrag: (e, d) ->
    @props.mark.x += d.x / @props.scale.horizontal
    @props.mark.y += d.y / @props.scale.vertical
    @props.onChange e

  handleTopLeftDrag: (e, d) ->
    @props.mark.x += d.x / @props.scale.horizontal
    @props.mark.y += d.y / @props.scale.vertical
    @props.mark.width -= d.x / @props.scale.horizontal
    @props.mark.height -= d.y / @props.scale.vertical
    @props.onChange e

  handleTopRightDrag: (e, d) ->
    @props.mark.y += d.y / @props.scale.vertical
    @props.mark.width += d.x / @props.scale.horizontal
    @props.mark.height -= d.y / @props.scale.vertical
    @props.onChange e

  handleBottomRightDrag: (e, d) ->
    @props.mark.width += d.x / @props.scale.horizontal
    @props.mark.height += d.y / @props.scale.vertical
    @props.onChange e

  handleBottomLeftDrag: (e, d) ->
    @props.mark.x += d.x / @props.scale.horizontal
    @props.mark.width -= d.x / @props.scale.horizontal
    @props.mark.height += d.y / @props.scale.vertical
    @props.onChange e

  normalizeMark: ->
    if @props.mark.width < 0
      @props.mark.x += @props.mark.width
      @props.mark.width *= -1

    if @props.mark.height < 0
      @props.mark.y += @props.mark.height
      @props.mark.height *= -1

    @props.onChange()

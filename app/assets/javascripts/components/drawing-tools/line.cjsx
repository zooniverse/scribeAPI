React = require 'react'
DrawingToolRoot = require './root'
Draggable = require '../../lib/draggable'
DeleteButton = require './delete-button'
DragHandle = require './drag-handle'

MINIMUM_LENGTH = 5
GRAB_STROKE_WIDTH = 6

module.exports = React.createClass
  displayName: 'LineTool'

  statics:
    defaultValues: ({x, y}) ->
      x1: x
      y1: y
      x2: x
      y2: y

    initMove: ({x, y}) ->
      x2: x
      y2: y

    initValid: (mark) ->
      {x1, y1, x2, y2} = mark
      DrawingToolRoot.distance(x1, y1, x2, y2) > MINIMUM_LENGTH

  render: ->
    {x1, y1, x2, y2} = @props.mark
    points = {x1, y1, x2, y2}

    <DrawingToolRoot tool={this}>
      <line {...points} />

      <Draggable onDrag={@handleStrokeDrag} disabled={@props.disabled}>
        <line {...points} strokeWidth={GRAB_STROKE_WIDTH / ((@props.scale.horizontal + @props.scale.vertical) / 2)} strokeOpacity="0" />
      </Draggable>

      {if @props.selected
        <g>
          <DeleteButton tool={this} x={(x1 + x2) / 2} y={(y1 + y2) / 2} />
          <DragHandle x={x1} y={y1} scale={@props.scale} onDrag={@handleHandleDrag.bind this, 1} />
          <DragHandle x={x2} y={y2} scale={@props.scale} onDrag={@handleHandleDrag.bind this, 2} />
        </g>}
    </DrawingToolRoot>

  handleStrokeDrag: (e, d) ->
    for n in [1..2]
      @props.mark["x#{n}"] += d.x / @props.scale.horizontal
      @props.mark["y#{n}"] += d.y / @props.scale.vertical
    @props.onChange e

  handleHandleDrag: (n, e, d) ->
    @props.mark["x#{n}"] += d.x / @props.scale.horizontal
    @props.mark["y#{n}"] += d.y / @props.scale.vertical
    @props.onChange e

React = require 'react'
DrawingToolRoot = require './root'
DragHandle = require './drag-handle'
Draggable = require '../../lib/draggable'
DeleteButton = require './delete-button'

FINISHER_RADIUS = 8
GRAB_STROKE_WIDTH = 6

DELETE_BUTTON_WEIGHT = 5 # Weight of the second point.

module.exports = React.createClass
  displayName: 'PolygonTool'

  statics:
    initCoords: null

    defaultValues: ({x, y}) ->
      points: []
      closed: null

    initStart: ({x, y}, mark) ->
      mark.points.push {x, y}
      points: mark.points

    initMove: ({x, y}, mark) ->
      mark.points[mark.points.length - 1] = {x, y}
      points: mark.points

    isComplete: (mark) ->
      mark.closed?

  render: ->
    averageScale = (@props.scale.horizontal + @props.scale.vertical) / 2
    finisherRadius = FINISHER_RADIUS / averageScale

    firstPoint = @props.mark.points[0]
    secondPoint = @props.mark.points[1]
    secondPoint ?=
      x: firstPoint.x + (finisherRadius * 2)
      y: firstPoint.y - (finisherRadius * 2)
    lastPoint = @props.mark.points[@props.mark.points.length - 1]

    points = ([x, y].join ',' for {x, y} in @props.mark.points)
    if @props.mark.closed
      points.push [firstPoint.x, firstPoint.y].join ','
    points = points.join '\n'

    deleteButtonPosition =
      x: (firstPoint.x + ((DELETE_BUTTON_WEIGHT - 1) * secondPoint.x)) / DELETE_BUTTON_WEIGHT
      y: (firstPoint.y + ((DELETE_BUTTON_WEIGHT - 1) * secondPoint.y)) / DELETE_BUTTON_WEIGHT

    <DrawingToolRoot tool={this}>
      <Draggable onDrag={@handleMainDrag} disabled={@props.disabled}>
        <g>
          {if @props.mark.closed is false
            <polyline points={points} fill="none" strokeWidth={GRAB_STROKE_WIDTH / averageScale} strokeOpacity="0" />}
          <polyline points={points} fill={'none' unless @props.mark.closed} />
        </g>
      </Draggable>

      {if @props.selected
        <g>
          <DeleteButton tool={this} x={deleteButtonPosition.x} y={deleteButtonPosition.y} />

          {for point, i in @props.mark.points
            point._key ?= Math.random()
            <DragHandle key={i} x={point.x} y={point.y} scale={@props.scale} onDrag={@handleHandleDrag.bind this, i} />}

          {unless @props.mark.closed?
            <g>
              {if @props.mark.points.length > 2
                <line className="guideline" x1={lastPoint.x} y1={lastPoint.y} x2={firstPoint.x} y2={firstPoint.y} />}
              <circle className="clickable" r={finisherRadius} cx={firstPoint.x} cy={firstPoint.y} onClick={@handleFinishClick.bind this, true} />
              <circle className="clickable" r={finisherRadius} cx={lastPoint.x} cy={lastPoint.y} onClick={@handleFinishClick.bind this, false} />
            </g>}
        </g>}
    </DrawingToolRoot>

  handleFinishClick: (closed) ->
    @props.mark.closed = closed
    @props.onChange()

  handleMainDrag: (e, d) ->
    for point in @props.mark.points
      point.x += d.x / @props.scale.horizontal
      point.y += d.y / @props.scale.vertical
    @props.onChange e

  handleHandleDrag: (index, e, d) ->
    @props.mark.points[index].x += d.x / @props.scale.horizontal
    @props.mark.points[index].y += d.y / @props.scale.vertical
    @props.onChange e

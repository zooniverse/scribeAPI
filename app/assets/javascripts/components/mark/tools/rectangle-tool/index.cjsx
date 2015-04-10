# @cjsx React.DOM
React          = require 'react'
Draggable      = require 'lib/draggable'
DragHandle     = require './drag-handle'
DeleteButton    = require './delete-button'

SELECTED_RADIUS = 20
MINIMUM_SIZE = 5
DELETE_BUTTON_ANGLE = 45
DELETE_BUTTON_DISTANCE = 9 / 10
DEBUG = false


module.exports = React.createClass
  displayName: 'RectangleTool'

  propTypes:
    key:  React.PropTypes.number.isRequired
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

  initCoords: null

  getInitialState: ->
    mark = @props.mark
    unless mark.status?
      mark.status = 'mark'
    mark: mark
    # set up the state in order to caluclate the polyline as rectangle
    x: @props.mark.x
    y: @props.mark.y
    width: @props.width
    height: @props.height

    buttonDisabled: false
    lockTool: false

  handleMainDrag: (e, d) ->
     @props.mark.x += d.x / @props.xScale
     @props.mark.y += d.y / @props.yScale
     @props.onChange e

  handleX1Y1Drag: (e, d) ->
    @props.mark.x += d.x / @props.xScale
    @props.mark.y += d.y / @props.yScale
    @props.mark.width -= d.x / @props.xScale
    @props.mark.height -= d.y / @props.yScale
    @props.onChange e
  
  handleX1Y2Drag: (e, d) ->
    @props.mark.x += d.x / @props.xScale
    @props.mark.width -= d.x / @props.xScale
    @props.mark.height += d.y / @props.yScale
    @props.onChange e

  handleX2Y1Drag: (e, d) ->
    @props.mark.y += d.y / @props.yScale
    @props.mark.width += d.x / @props.xScale
    @props.mark.height -= d.y / @props.yScale
    @props.onChange e

  handleX2Y2Drag: (e, d) ->
    @props.mark.width += d.x / @props.xScale
    @props.mark.height += d.y / @props.yScale
    @props.onChange e

  getDeleteButtonPosition: ->
    theta = (DELETE_BUTTON_ANGLE) * (Math.PI / 180)
    x: (SELECTED_RADIUS / @props.xScale) * Math.cos theta
    y: -1 * (SELECTED_RADIUS / @props.yScale) * Math.sin theta

  handleMouseDown: ->
    @props.onSelect @props.mark

  render: ->
    classString = "rectangleTool"
    x1 = @props.mark.x
    width = @props.mark.width
    x2 = x1 + width
    y1 = @props.mark.y
    height = @props.mark.height
    y2 = y1 + height

    points = [
      [x1, y1].join ','
      [x2, y1].join ','
      [x2, y2].join ','
      [x1, y2].join ','
      [x1, y1].join ','
    ].join '\n'

    <g 
      className = {classString} 
      tool={this}
      onMouseDown={@props.onSelect unless @props.disabled}
    >
      <g 
        className = {classString} 
        onMouseDown={@props.onSelect unless @props.disabled}
      >

        <Draggable onDrag = {@handleMainDrag} >
          <polyline points={points} strokeWidth="5" stroke="orange" fill="none"/>
        </Draggable>

        { if @props.selected
          <g>
            <DeleteButton tool={this} x={x1 + (width * DELETE_BUTTON_DISTANCE)} y={y1} />
            <DragHandle x={x1} y={y1} onDrag={@handleX1Y1Drag} />
            <DragHandle x={x2} y={y1} onDrag={@handleX2Y1Drag} />
            <DragHandle x={x2} y={y2} onDrag={@handleX2Y2Drag} />
            <DragHandle x={x1} y={y2} onDrag={@handleX1Y2Drag} />
          </g>
        }
      </g>

    </g>








 
    


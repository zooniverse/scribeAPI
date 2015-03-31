React = require 'react'
DrawingToolRoot = require './root'
Draggable = require 'lib/draggable'
DeleteButton = require './delete-button'

RADIUS = 10
SELECTED_RADIUS = 20
CROSSHAIR_SPACE = 0.2
CROSSHAIR_WIDTH = 1
DELETE_BUTTON_ANGLE = 45

module.exports = React.createClass
  displayName: 'SuperAwesomePointTool'

  statics:
    defaultValues: ({x, y}) ->
      {x, y}

    initMove: ({x, y}) ->
      {x, y}

  getDeleteButtonPosition: ->
    theta = (DELETE_BUTTON_ANGLE) * (Math.PI / 180)
    x: (SELECTED_RADIUS / @props.xScale) * Math.cos theta
    y: -1 * (SELECTED_RADIUS / @props.yScale) * Math.sin theta

  render: ->
    # averageScale = (@props.xScale + @props.yScale) / 2

    # crosshairSpace = CROSSHAIR_SPACE / averageScale
    # crosshairWidth = CROSSHAIR_WIDTH / averageScale
    # selectedRadius = SELECTED_RADIUS / averageScale

    # radius = if @props.selected
    #   SELECTED_RADIUS / averageScale
    # else
    #   RADIUS / averageScale

    # <DrawingToolRoot tool={this} transform="translate(#{@props.mark.x}, #{@props.mark.y})">
    #   <line x1="0" y1={-1 * crosshairSpace * selectedRadius} x2="0" y2={-1 * selectedRadius} strokeWidth={crosshairWidth} />
    #   <line x1={-1 * crosshairSpace * selectedRadius} y1="0" x2={-1 * selectedRadius} y2="0" strokeWidth={crosshairWidth} />
    #   <line x1="0" y1={crosshairSpace * selectedRadius} x2="0" y2={selectedRadius} strokeWidth={crosshairWidth} />
    #   <line x1={crosshairSpace * selectedRadius} y1="0" x2={selectedRadius} y2="0" strokeWidth={crosshairWidth} />
    #   <Draggable onDrag={@handleDrag} disabled={@props.disabled}>
    #     <circle r={radius} />
    #   </Draggable>
    # </DrawingToolRoot>

    <text 
      x={@props.mark.x} 
      y={@props.mark.y} 
      fill="red" 
      fontSize="55">
      SuperAwesomePoint
    </text>

  handleDrag: (e, d) ->
    console.log 'handleDrag()'
    @props.mark.x += d.x / @props.xScale
    @props.mark.y += d.y / @props.yScale
    @props.onChange e

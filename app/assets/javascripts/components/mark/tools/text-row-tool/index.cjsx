React           = require 'react'
DrawingToolRoot = require './root'
Draggable       = require 'lib/draggable'
DeleteButton    = require './delete-button'
DragHandle      = require './drag-handle'

RADIUS = 10
SELECTED_RADIUS = 20
CROSSHAIR_SPACE = 0.2
CROSSHAIR_WIDTH = 1
DELETE_BUTTON_ANGLE = 45

STROKE_WIDTH = 1.5
SELECTED_STROKE_WIDTH = 2.5

DEFAULT_HEIGHT = 100

module.exports = React.createClass
  displayName: 'TextRowTool'

  statics:
    defaultValues: ({x, y}) ->
      x: x
      y: y - DEFAULT_HEIGHT/2 # x and y will be the initial click position (not super useful as of yet)
      yUpper: y - DEFAULT_HEIGHT/2
      yLower: y + DEFAULT_HEIGHT/2

    initMove: ({x, y}) ->
      x: x
      y: y - DEFAULT_HEIGHT/2
      yUpper: y - DEFAULT_HEIGHT/2 # not sure if these are needed
      yLower: y + DEFAULT_HEIGHT/2

  getDeleteButtonPosition: ->
    # theta = (DELETE_BUTTON_ANGLE) * (Math.PI / 180)
    # x: (SELECTED_RADIUS / @props.xScale) * Math.cos theta
    # y: -1 * (SELECTED_RADIUS / @props.yScale) * Math.sin theta
    x: 100-@props.mark.x
    y: (@props.mark.yLower-@props.mark.yUpper)/2

  getUpperHandlePosition: ->
    x: @props.ref.props.width/2 - @props.mark.x
    y: @props.mark.yUpper - @props.mark.y

  getLowerHandlePosition: ->
    x: @props.ref.props.width/2 - @props.mark.x
    y: @props.mark.yLower - @props.mark.y

  render: ->
    averageScale = (@props.xScale + @props.yScale) / 2
    crosshairSpace = CROSSHAIR_SPACE / averageScale
    crosshairWidth = CROSSHAIR_WIDTH / averageScale
    selectedRadius = SELECTED_RADIUS / averageScale
    radius = if @props.selected
      SELECTED_RADIUS / averageScale
    else
      RADIUS / averageScale

    scale = (@props.xScale + @props.yScale) / 2

    <g
      tool={this}
      transform="translate(#{@props.mark.x}, #{@props.mark.y})"
      onMouseDown={@handleMouseDown}
    >
      <g
        className="drawing-tool-main"
        fill='transparent'
        stroke='#f60'
        strokeWidth={SELECTED_STROKE_WIDTH/scale}
        onMouseDown={@props.onSelect unless @props.disabled}
      >
        <Draggable onDrag={@handleDrag}>
          <rect x={0-@props.mark.x} y={0} width="100%" height={@props.mark.yLower-@props.mark.yUpper} />
        </Draggable>

        { if @props.selected
          <g>
            <DragHandle tool={this} onDrag={@handleUpperResize} position={@getUpperHandlePosition()} />
            <DragHandle tool={this} onDrag={@handleLowerResize} position={@getLowerHandlePosition()} />
            <DeleteButton tool={this} position={@getDeleteButtonPosition()} />
          </g>
        }

      </g>
    </g>

    # <text x={@props.mark.x} y={@props.mark.y} fill="red" fontSize="55">SuperAwesomePoint!</text>

  handleDrag: (e, d) ->
    @props.mark.x += d.x / @props.xScale
    @props.mark.y += d.y / @props.yScale
    @props.onChange e

  handleUpperResize: (e, d) ->
    console.log 'HANDLE UPPER RESIZE'
    @props.mark.yUpper += d.y / @props.yScale
    @props.onChange e

  handleLowerResize: (e, d) ->
    console.log 'HANDLE LOWER RESIZE'
    @props.mark.yLower += d.y / @props.yScale
    @props.onChange e


  # handleDrag: (e, d) ->
  #   console.log 'handleDrag()'
  #   offset = @props.getEventOffset e
  #   @props.mark.x = offset.x
  #   @props.mark.y = offset.y
  #   @props.onChange()

  handleMouseDown: ->
    console.log 'handleMouseDown()'
    @props.onSelect @props.mark # unless @props.disabled

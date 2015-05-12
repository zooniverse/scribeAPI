React            = require 'react'
DrawingToolRoot  = require './root'
Draggable        = require 'lib/draggable'
DeleteButton     = require './delete-button'
DragHandle       = require './drag-handle'
MarkButtonMixin  = require 'lib/mark-button-mixin'

RADIUS = 10
SELECTED_RADIUS = 20
CROSSHAIR_SPACE = 0.2
CROSSHAIR_WIDTH = 1
DELETE_BUTTON_ANGLE = 45

STROKE_COLOR = '#f60'
SELECTED_STROKE_COLOR = "rgb(100,100,100)"
STROKE_WIDTH = 1.5
SELECTED_STROKE_WIDTH = 2.5

DEFAULT_HEIGHT = 100
MINIMUM_HEIGHT = 25

module.exports = React.createClass
  displayName: 'TextRowTool'

  mixins: [MarkButtonMixin] # adds MarkButton and helper methods to each mark

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
    x: 100
    y: (@props.mark.yLower-@props.mark.yUpper)/2

  getUpperHandlePosition: ->
    x: @props.ref.props.width/2
    y: @props.mark.yUpper - @props.mark.y

  getLowerHandlePosition: ->
    x: @props.ref.props.width/2
    y: @props.mark.yLower - @props.mark.y

  getMarkButtonPosition: ->
    x: @props.ref.props.width - 100
    y: (@props.mark.yLower-@props.mark.yUpper)/2

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
      transform="translate(0, #{@props.mark.y})"
      onMouseDown={@handleMouseDown}
    >
      <g
        className="mark-tool text-row-tool"
        fill='transparent'
        stroke={ if @props.selected then STROKE_COLOR else SELECTED_STROKE_COLOR }
        strokeWidth={ if @props.selected then SELECTED_STROKE_WIDTH/scale else STROKE_WIDTH/scale }
        onMouseDown={@props.onSelect unless @props.disabled}
      >
        <Draggable onDrag={@handleDrag}>
          <rect
            x="0"
            y="0"
            width="100%"
            height={@props.mark.yLower-@props.mark.yUpper}
          />
        </Draggable>

        { if @props.selected and not @state.locked
            <g>
              <DragHandle   tool={this} onDrag={@handleUpperResize} position={@getUpperHandlePosition()} />
              <DragHandle   tool={this} onDrag={@handleLowerResize} position={@getLowerHandlePosition()} />
              <DeleteButton tool={this} position={@getDeleteButtonPosition()} />
            </g>
        }

        { # REQUIRES MARK-BUTTON-MIXIN
          if @props.selected then @renderMarkButton()
        }

      </g>
    </g>

  handleDrag: (e, d) ->
    return if @state.locked
    # @props.mark.x += d.x / @props.xScale
    @props.mark.y += d.y / @props.yScale
    @props.mark.yUpper += d.y / @props.yScale
    @props.mark.yLower += d.y / @props.yScale
    @props.onChange e

  handleUpperResize: (e, d) ->
    @props.mark.yUpper += d.y / @props.yScale
    @props.mark.y += d.y / @props.yScale # fix weird resizing problem
    @props.onChange e

  handleLowerResize: (e, d) ->
    @props.mark.yLower += d.y / @props.yScale
    @props.onChange e

  handleMouseDown: ->
    console.log 'handleMouseDown()'
    @props.onSelect @props.mark # unless @props.disabled

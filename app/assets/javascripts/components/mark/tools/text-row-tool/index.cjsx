React            = require 'react'
DrawingToolRoot  = require './root'
Draggable        = require 'lib/draggable'
DeleteButton     = require './delete-button'
DragHandle       = require './drag-handle'
MarkButton       = require './mark-button'

RADIUS = 10
SELECTED_RADIUS = 20
CROSSHAIR_SPACE = 0.2
CROSSHAIR_WIDTH = 1
DELETE_BUTTON_ANGLE = 45

STROKE_COLOR = '#f60'
STROKE_WIDTH = 1.5
SELECTED_STROKE_WIDTH = 2.5

DEFAULT_HEIGHT = 100
MINIMUM_HEIGHT = 25



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

  getInitialState: ->
    markStatus: 'waiting-for-mark'

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
        stroke=STROKE_COLOR
        strokeWidth={SELECTED_STROKE_WIDTH/scale}
        onMouseDown={@props.onSelect unless @props.disabled}
      >
        <Draggable onDrag={@handleDrag}>
          <rect x={0} y={0} width="100%" height={@props.mark.yLower-@props.mark.yUpper} />
        </Draggable>

        { if @props.selected
          <g>
            <DragHandle   tool={this} onDrag={@handleUpperResize} position={@getUpperHandlePosition()} />
            <DragHandle   tool={this} onDrag={@handleLowerResize} position={@getLowerHandlePosition()} />
            <DeleteButton tool={this} position={@getDeleteButtonPosition()} />
            <MarkButton   tool={this} onDrag={@onClickMarkButton} position={@getMarkButtonPosition()} />
          </g>
        }

      </g>
    </g>

  handleDrag: (e, d) ->
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

  onClickMarkButton: ->
    # @props.submitMark(@props.mark) # disable for now -STI
    console.log 'TRANSCRIBE CLICK!'
    console.log 'THIS TOOL: ', @

    markStatus = @state.markStatus
    switch markStatus
      when 'waiting-for-mark'
        @setState
          markStatus: 'mark-finished'
          locked: false
        # @props.submitMark(@props.key)
        console.log 'Mark submitted. Click TRANSCRIBE to begin transcribing.'
      when 'mark-finished'
        @setState
          markStatus: 'transcribe'
          locked: true
        # @props.onClickTranscribe(@state.mark.key)
        # @transcribeMark(mark)

        console.log 'Going into TRANSCRIBE mode. Stand by.'
      when 'transcribe'
        @setState
          markStatus: 'transcribe-finished'
          locked: true
        # @submitTranscription()
        console.log 'Transcription submitted.'
      when 'transcribe-finished'
        @setState locked: true
        console.log 'All done. Nothing left to do here.'
      else
        @setState locked: true
        console.log 'WARNING: Unknown state in handleToolProgress()'

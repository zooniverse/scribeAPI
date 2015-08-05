# @cjsx React.DOM
React           = require 'react'
Draggable       = require 'lib/draggable'
DragHandle      = require './drag-handle'
DeleteButton    = require './delete-button'
MarkButtonMixin = require 'lib/mark-button-mixin'

MINIMUM_SIZE = 5
DELETE_BUTTON_ANGLE = 45
DELETE_BUTTON_DISTANCE = 9 / 10
DEBUG = false

markStyles =

  prior:
    strokeColor:         'pink' # rgba(90,200,90,0.5)'
    strokeWidth:         2.0
    hoverFill:           'rgba(100,100,0,0.5)'
    disabledStrokeColor: 'rgba(90,200,90,0.5)'
    disabledStrokeWidth: 2.0
    disabledHoverFill:   'transparent'

  selected:
    strokeColor:         '#43bbfd'
    strokeWidth:         2.5
    hoverFill:           'transparent'
    disabledStrokeColor: '#43bbfd'
    disabledStrokeWidth: 2.0
    disabledHoverFill:   'transparent'

  regular:
    strokeColor:         'pink' #rgba(100,100,0,0.5)'
    strokeWidth:         2.0
    hoverFill:           'transparent'
    disabledStrokeColor: 'rgba(100,100,0,0.5)'
    disabledStrokeWidth: 2.0
    disabledHoverFill:   'transparent'

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
    return if @state.locked
    return if @props.disabled
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

  getMarkButtonPosition: ->
    x: @props.mark.x + @props.mark.width
    y: @props.mark.y + @props.mark.height + 20 / @props.yScale

  handleMouseDown: ->
    @props.onSelect @props.mark

  render: ->
    x1 = @props.mark.x
    width = @props.mark.width
    x2 = x1 + width
    y1 = @props.mark.y
    height = @props.mark.height
    y2 = y1 + height

    scale = (@props.xScale + @props.yScale) / 2

    markStyle = @getMarkStyle @props.mark, @props.selected, @props.isPriorMark

    points = [
      [x1, y1].join ','
      [x2, y1].join ','
      [x2, y2].join ','
      [x1, y2].join ','
      [x1, y1].join ','
    ].join '\n'

    <g
      tool={this}
      onMouseDown={@props.onSelect unless @props.disabled}
      title={@props.mark.label}
    >
      <g
        className="rectangle-tool#{if @props.disabled then ' locked' else ''}"
        onMouseDown={@props.onSelect unless @props.disabled}
        stroke={markStyle.strokeColor}
        strokeWidth={markStyle.strokeWidth/scale}
      >

        <Draggable onDrag = {@handleMainDrag} >
          <g
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
                  points=\"#{points}\"
                  fill=\"transparent\"
                  filter=\"#{if @props.selected then 'url(#dropShadow)' else 'none'}\"
                />

              "
            }
          />

        </Draggable>

        { if @props.selected and not @props.disabled
          <g>
            <DeleteButton tool={this} x={x1 + (width * DELETE_BUTTON_DISTANCE)} y={y1} />
            <DragHandle tool={this} x={x1} y={y1} onDrag={@handleX1Y1Drag} />
            <DragHandle tool={this} x={x2} y={y1} onDrag={@handleX2Y1Drag} />
            <DragHandle tool={this} x={x2} y={y2} onDrag={@handleX2Y2Drag} />
            <DragHandle tool={this} x={x1} y={y2} onDrag={@handleX1Y2Drag} />
          </g>
        }

        { # REQUIRES MARK-BUTTON-MIXIN
          console.log 'IS TRANSCRIBABLE? ', @props.isTranscribable
          if @props.selected or @state.markStatus is 'transcribe-enabled'
            @renderMarkButton() if @props.isTranscribable
        }

      </g>

    </g>

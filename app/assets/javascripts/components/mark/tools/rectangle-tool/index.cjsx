# @cjsx React.DOM
React           = require 'react'
Draggable       = require 'lib/draggable'
DragHandle      = require './drag-handle'
DeleteButton    = require 'components/buttons/delete-mark'
MarkButtonMixin = require 'lib/mark-button-mixin'

MINIMUM_SIZE = 5
DELETE_BUTTON_ANGLE = 45
DELETE_BUTTON_DISTANCE_X = 12
DELETE_BUTTON_DISTANCE_Y = 12
DEBUG = false

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
    x = @props.mark.x + @props.mark.width + DELETE_BUTTON_DISTANCE_X / @props.xScale
    y = @props.mark.y - DELETE_BUTTON_DISTANCE_Y / @props.yScale
    {x, y}

  getMarkButtonPosition: ->
    x: @props.mark.x + @props.mark.width
    y: @props.mark.y + @props.mark.height + 20 / @props.yScale

  handleMouseDown: ->
    @props.onSelect @props.mark

  render: ->
    classes = []
    classes.push 'transcribable' if @props.isTranscribable
    classes.push if @props.disabled then 'committed' else 'uncommitted'
    classes.push "tanscribing" if @checkLocation()

    x1 = @props.mark.x
    width = @props.mark.width
    x2 = x1 + width
    y1 = @props.mark.y
    height = @props.mark.height
    y2 = y1 + height

    scale = (@props.xScale + @props.yScale) / 2

    points = [
      [x1, y1].join ','
      [x2, y1].join ','
      [x2, y2].join ','
      [x1, y2].join ','
      [x1, y1].join ','
    ].join '\n'

    <g
      tool={this}
      onMouseDown={@props.onSelect}
      title={@props.mark.label}
    >
      <g
        className="rectangle-tool#{if @props.disabled then ' locked' else ''}"
      >

        <Draggable onDrag = {@handleMainDrag} >
          <g
            className="tool-shape #{classes.join ' '}"
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
                  #{if @props.mark.color? then "stroke=\"#{@props.mark.color}\""}
                  points=\"#{points}\"
                  filter=\"#{if @props.selected then 'url(#dropShadow)' else 'none'}\"
                />
              "
            }
          />

        </Draggable>

        { if @props.selected
            <DeleteButton onClick={@props.onDestroy} scale={scale} x={@getDeleteButtonPosition().x} y={@getDeleteButtonPosition().y}/>
        }
        { if @props.selected && not @props.disabled
            <g>
              <DragHandle tool={this} x={x1} y={y1} onDrag={@handleX1Y1Drag} />
              <DragHandle tool={this} x={x2} y={y1} onDrag={@handleX2Y1Drag} />
              <DragHandle tool={this} x={x2} y={y2} onDrag={@handleX2Y2Drag} />
              <DragHandle tool={this} x={x1} y={y2} onDrag={@handleX1Y2Drag} />
            </g>
        }

        { # REQUIRES MARK-BUTTON-MIXIN
          if @props.selected or @state.markStatus is 'transcribe-enabled'
            @renderMarkButton() if @props.isTranscribable
        }

      </g>

    </g>

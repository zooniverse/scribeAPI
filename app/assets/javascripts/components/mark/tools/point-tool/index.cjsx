React           = require 'react'
DrawingToolRoot = require './root'
Draggable       = require 'lib/draggable'
DeleteButton    = require './delete-button'
MarkButtonMixin = require 'lib/mark-button-mixin'

RADIUS = 10
SELECTED_RADIUS = 20
CROSSHAIR_SPACE = 0.2
CROSSHAIR_WIDTH = 1
DELETE_BUTTON_ANGLE = 45

markStyles =

  prior:
    strokeColor:         'rgba(90,200,90,0.5)'
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
    strokeColor:         'rgba(100,100,0,0.5)'
    strokeWidth:         2.0
    hoverFill:           'transparent'
    disabledStrokeColor: 'rgba(100,100,0,0.5)'
    disabledStrokeWidth: 2.0
    disabledHoverFill:   'transparent'

module.exports = React.createClass
  displayName: 'PointTool'

  mixins: [MarkButtonMixin]

  statics:
    defaultValues: ({x, y}) ->
      {x, y}

    initMove: ({x, y}) ->
      {x, y}

  getDeleteButtonPosition: ->
    theta = (DELETE_BUTTON_ANGLE) * (Math.PI / 180)
    x: (SELECTED_RADIUS / @props.xScale) * Math.cos theta
    y: -1 * (SELECTED_RADIUS / @props.yScale) * Math.sin theta

  getMarkButtonPosition: ->
    x: SELECTED_RADIUS/@props.xScale
    y: SELECTED_RADIUS/@props.yScale

  handleDrag: (e, d) ->
    return if @state.locked
    return if @props.disabled
    @props.mark.x += d.x / @props.xScale
    @props.mark.y += d.y / @props.yScale
    @props.onChange e

  handleMouseDown: ->
    @props.onSelect @props.mark unless @props.disabled

  render: ->
    if @state.markStatus is 'mark-committed'
      isPriorMark = true
      @props.disabled = true

    averageScale = (@props.xScale + @props.yScale) / 2
    crosshairSpace = CROSSHAIR_SPACE / averageScale
    crosshairWidth = CROSSHAIR_WIDTH / averageScale
    selectedRadius = SELECTED_RADIUS / averageScale

    radius = if @props.selected or @props.disabled
      SELECTED_RADIUS / averageScale
    else
      RADIUS / averageScale

    scale = (@props.xScale + @props.yScale) / 2

    # DETERMINE MARK STYLE
    markStyle = @getMarkStyle @props.mark, @props.selected, isPriorMark

    <g
      tool={this}
      transform="translate(#{@props.mark.x}, #{@props.mark.y})"
      onMouseDown={@handleMouseDown}
      title={@props.mark.label}
    >
      <g
        className="mark-tool point-tool#{if @props.disabled then ' locked' else ''}"
        fill='transparent'
        stroke={markStyle.strokeColor}
        strokeWidth={markStyle.strokeWidth/scale}
        onMouseDown={@handleMouseDown}
      >

        <line x1="0" y1={-1 * crosshairSpace * selectedRadius} x2="0" y2={-1 * selectedRadius} strokeWidth={crosshairWidth} />
        <line x1={-1 * crosshairSpace * selectedRadius} y1="0" x2={-1 * selectedRadius} y2="0" strokeWidth={crosshairWidth} />
        <line x1="0" y1={crosshairSpace * selectedRadius} x2="0" y2={selectedRadius} strokeWidth={crosshairWidth} />
        <line x1={crosshairSpace * selectedRadius} y1="0" x2={selectedRadius} y2="0" strokeWidth={crosshairWidth} />
        <Draggable onDrag={@handleDrag}>

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
                <circle
                  r=\"#{radius}\"
                  filter=\"#{if @props.selected then 'url(#dropShadow)' else 'none'}\"
                />
              "
            }
          />

        </Draggable>

        { if @props.selected and not @props.disabled
          <DeleteButton tool={this} getDeleteButtonPosition={@getDeleteButtonPosition} />
        }

        { # REQUIRES MARK-BUTTON-MIXIN
          if @props.selected or @state.markStatus is 'transcribe-enabled' then @renderMarkButton()
        }

      </g>
    </g>

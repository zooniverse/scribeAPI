React           = require 'react'
DrawingToolRoot = require './root'
Draggable       = require 'lib/draggable'
DeleteButton    = require './delete-button'
MarkButtonMixin = require 'lib/mark-button-mixin'

# DEFAULT SETTINGS
RADIUS = 10
SELECTED_RADIUS = 20
CROSSHAIR_SPACE = 0.2
CROSSHAIR_WIDTH = 1
DELETE_BUTTON_ANGLE = 45

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
    classes = []
    classes.push 'transcribable' if @props.isTranscribable
    classes.push if @props.disabled then 'committed' else 'uncommitted'

    if @state.markStatus is 'mark-committed'
      isPriorMark = true
      @props.disabled = true

    averageScale = (@props.xScale + @props.yScale) / 2

    console.log 'AVERAGE SCALE = ', averageScale

    crosshairSpace = CROSSHAIR_SPACE / averageScale
    crosshairWidth = CROSSHAIR_WIDTH / averageScale
    selectedRadius = SELECTED_RADIUS / averageScale

    radius = if @props.selected or @props.disabled
      SELECTED_RADIUS / averageScale
    else
      RADIUS / averageScale

    scale = (@props.xScale + @props.yScale) / 2

    <g
      tool={this}
      transform="translate(#{@props.mark.x}, #{@props.mark.y})"
      onMouseDown={@handleMouseDown}
      title={@props.mark.label}
    >
      <g
        className='point-tool'
        onMouseDown={@handleMouseDown}
      >

        <Draggable onDrag={@handleDrag}>
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

                <g #{if @props.mark.color? then "stroke=\"#{@props.mark.color}\""} >
                  <line x1=\"0\" y1=\"#{-1 * crosshairSpace * selectedRadius}\" x2=\"0\" y2=\"#{-1 * selectedRadius}\" strokeWidth=\"#{crosshairWidth}\" />
                  <line x1=\"#{-1 * crosshairSpace * selectedRadius}\" y1=\"0\" x2=\"#{-1 * selectedRadius}\" y2=\"0\" strokeWidth=\"#{crosshairWidth}\" />
                  <line x1=\"0\" y1=\"#{crosshairSpace * selectedRadius}\" x2=\"0\" y2=\"#{selectedRadius}\" strokeWidth=\"#{crosshairWidth}\" />
                  <line x1=\"#{crosshairSpace * selectedRadius}\" y1=\"0\" x2=\"#{selectedRadius}\" y2=\"0\" strokeWidth=\"#{crosshairWidth}\" />
                </g>

                <circle
                  #{if @props.mark.color? then "stroke=\"#{@props.mark.color}\""}
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
          console.log 'IS TRANSCRIBABLE? ', @props.isTranscribable
          if @props.selected or @state.markStatus is 'transcribe-enabled'
            @renderMarkButton() if @props.isTranscribable
        }

      </g>
    </g>

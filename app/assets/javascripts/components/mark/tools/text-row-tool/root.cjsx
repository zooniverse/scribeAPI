React = require 'react'

STROKE_WIDTH = 1.5
SELECTED_STROKE_WIDTH = 2.5

module.exports = React.createClass
  displayName: 'DrawingToolRoot'

  statics:
    distance: (x1, y1, x2, y2) ->
      Math.sqrt Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2)

  getDefaultProps: ->
    tool: null

  getInitialState: ->
    destroying: false

  render: ->
    console.log "TEXTROW TOOL"
    console.log "TEXTROW TOOL"
    console.log "TEXTROW TOOL PROPS", @props 
    toolProps = @props.tool.props

    rootProps =
      'data-disabled': toolProps.disabled or null
      'data-selected': toolProps.selected or null
      'data-destroying': @props.tool.state?.destroying or null
      style: color: toolProps.color

    scale = (toolProps.xScale + toolProps.yScale) / 2

    mainStyle =
      fill: 'transparent'
      stroke: 'red'
      strokeWidth: if toolProps.selected
        SELECTED_STROKE_WIDTH / scale
      else
        STROKE_WIDTH / scale

    <g 
      className="drawing-tool"
      data-disabled={toolProps.disabled or null}
      data-selected= {toolProps.selected or null}
      data-destroying={@props.tool.state?.destroying or null}
      color="red"
    >
      <g 
        className="drawing-tool-main"
        fill='transparent'
        stroke='#f60'
        strokeWidth={SELECTED_STROKE_WIDTH/scale}
        onMouseDown={toolProps.onSelect unless toolProps.disabled}
      >
        {@props.children}
      </g>
    </g>

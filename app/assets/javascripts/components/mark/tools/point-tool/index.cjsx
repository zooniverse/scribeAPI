# @cjsx React.DOM
# Model = require '../../data/model'
React = require 'react'
Draggable = require '../../../../lib/draggable'
DeleteButton = require './delete-button'

module.exports = React.createClass
  displayName: 'PointTool'

  statics:
    defaultValues: ->
      @initStart arguments...

    initStart: ->
      @initMove arguments...

    initMove: ({x, y}) ->
      {x, y}

  getInitialState: ->
    x: @props.mark.x
    y: @props.mark.y

  render: ->
    
    fillColor   = 'rgba(0,0,0,0.5)'
    strokeColor = '#fff'
    radius = 40

    console.log 'PROPS: ', @props

    # radius = if @props.disabled
    #   4 
    # else if @props.selected
    #   12
    # else
    #   6

    strokeWidth = 3

    transform = "
      translate(#{@state.x}, #{@state.y})
      scale(#{1}, #{1})
    "

    <g className="point drawing-tool" transform={transform}>
      <Draggable onDrag={@handleDrag} onStart={@props.handleMarkClick.bind null, @props.mark} >
        <g strokeWidth={strokeWidth}>
          <circle r={radius + (strokeWidth / 2)} stroke={strokeColor} fill={fillColor} />
        </g>
      </Draggable>
      
      { if @props.isSelected
          <DeleteButton transform="translate(#{radius}, #{-radius})" onClick={@props.onClickDelete} /> }

    </g>

  handleDrag: (e) ->
    console.log 'handleDrag():'
    @update @props.getEventOffset(e)

  update: ({x,y}) ->
    # console.log 'updateMark() ', e
    @setState {x,y}
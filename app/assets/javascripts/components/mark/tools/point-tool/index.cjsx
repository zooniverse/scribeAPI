# @cjsx React.DOM
# Model = require '../../data/model'
React = require 'react'
Draggable = require '../lib/draggable'
DeleteButton = require './mark/delete-button'

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

  updateMark: ({x,y}) ->
    # console.log 'updateMark() ', e
    @setState {x,y}

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

    # transform = "
    #   translate(#{@props.mark.x}, #{@props.mark.y})
    #   scale(#{1 / @props.scale.horizontal}, #{1 / @props.scale.vertical})
    # "

    <g className="point drawing-tool" transform={transform} data-disabled={@props.disabled || null} data-selected={@props.selected || null}>
      <Draggable onStart={@props.select} onDrag={@handleDrag}>
        <g strokeWidth={strokeWidth}>
          <circle r={radius + (strokeWidth / 2)} stroke={strokeColor} fill={fillColor} />
        </g>
      </Draggable>
      <DeleteButton transform="translate(#{radius}, #{-radius})" onClick={@props.onClickDelete} />
    </g>

  handleDrag: (e) ->
    @updateMark @props.getEventOffset(e)
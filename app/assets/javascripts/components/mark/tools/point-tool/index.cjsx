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
    console.log ' SALKSJLAKSJALSKJ PROPS: ', @props.mark
    # mark: @props.mark
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
      <Draggable onDrag={@handleDrag}>
        <g strokeWidth={strokeWidth}>
          <circle r={radius + (strokeWidth / 2)} stroke={strokeColor} fill={fillColor} />
        </g>
      </Draggable>
      <DeleteButton transform="translate(#{radius}, #{-radius})" />
    </g>

  handleDrag: (e) ->
    console.log 'handleDrag():'
    @updateMark @props.getEventOffset(e)

  updateMark: ({x,y}) ->
    # console.log 'updateMark() ', e
    @setState {x,y}
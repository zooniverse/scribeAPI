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
    mark: @props.mark
  
  componentWillReceiveProps: ->
    @setState 
      mark: @props.mark, =>
        @forceUpdate()

  render: ->
    
    fillColor   = 'rgba(0,0,0,0.5)'
    strokeColor = '#fff'
    radius = 40

    strokeWidth = 3

    transform = "
      translate(#{@state.mark.x}, #{@state.mark.y})
      scale(#{1}, #{1})
    "

    <g className="point drawing-tool" transform={transform}>
      <text fill='blue' fontSize='30'>{@props.mark.key}</text>
      <Draggable onDrag={@handleDrag} onStart={@props.handleMarkClick.bind null, @props.mark} >
        <g strokeWidth={strokeWidth}>
          <circle r={radius + (strokeWidth / 2)} stroke={strokeColor} fill={fillColor} />
        </g>
      </Draggable>
      
      { if @props.isSelected
          <DeleteButton 
            transform="translate(#{radius}, #{-radius})" 
            onClick={@props.onClickDelete.bind null, @props.key} /> 
      }

    </g>

  handleDrag: (e) ->
    console.log 'handleDrag():'
    @update @props.getEventOffset(e)

  update: ({x,y}) ->
    # console.log 'updateMark() ', e
    @setState {x,y}
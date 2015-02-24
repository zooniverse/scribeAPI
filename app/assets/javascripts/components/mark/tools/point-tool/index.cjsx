# @cjsx React.DOM
React = require 'react'
Draggable = require 'lib/draggable'
DeleteButton = require './delete-button'

DEBUG = false

module.exports = React.createClass
  displayName: 'PointTool'

  propTypes:
    key:  React.PropTypes.number.isRequired
    mark: React.PropTypes.object.isRequired

  getInitialState: ->
    mark: @props.mark
  
  componentWillReceiveProps: ->
    @setState 
      mark: @props.mark, =>
        @forceUpdate()

  handleDrag: (e) ->
    console.log 'E: ', e
    @update @props.getEventOffset(e)

  update: ({ex,ey}) ->
    console.log "(x,y) = (#{ex},#{ey})"
    mark = @state.mark
    mark.x = ex
    mark.y = ey
    @setState mark: mark

  render: ->
    
    fillColor   = 'rgba(0,0,0,0.30)'
    strokeColor = '#fff'
    radius = 40
    strokeWidth = 3

    transform = "
      translate(#{@state.mark.x}, #{@state.mark.y})
      scale(#{1}, #{1})
    "

    <g className="point-tool tool" transform={transform}>

      { if DEBUG
          <text fill='blue' fontSize='30'>
            {@props.mark.key}
          </text>
      }

      <Draggable 
        onStart={@props.handleMarkClick.bind null, @props.mark} 
        onDrag={@handleDrag} >

        <g strokeWidth={strokeWidth}>
          <circle 
            r={radius + (strokeWidth / 2)} 
            stroke={strokeColor} 
            fill={fillColor} 
          />
        </g>

      </Draggable>
      
      { if @props.isSelected
          <DeleteButton 
            transform="translate(#{radius}, #{-radius})" 
            onClick={@props.onClickDelete.bind null, @props.mark.key} /> 
      }

    </g>
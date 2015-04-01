# @cjsx React.DOM
React = require 'react'

DESTROY_TRANSITION_DURATION = 0

module.exports = React.createClass
  displayName: 'DeleteButton'

  getDefaultProps: ->
    x: 0
    y: 0
    rotate: 0

  render: ->
    fillColor = 'red'
    strokeColor = '#000'
    strokeWidth = 3
    radius = 20

    cross = "
      M #{-radius * 0.6 } 0
      L #{ radius * 0.6 } 0
      M 0 #{-radius * 0.6 }
      L 0 #{radius * 0.6 }
    "

    <g 
      transform = "
        translate(#{0}, #{@props.y})
        rotate(#{@props.rotate})
      "
      className="clickable drawing-tool-delete-button" 
      stroke={strokeColor} 
      strokeWidth={strokeWidth} 
      onClick={@destroyTool} 
    >
      <circle r={radius} fill={fillColor} />
      <path d={cross} transform="rotate(45)" />
    </g>

  destroyTool: ->
    console.log 'DESTROY TOOL'
    @props.tool.setState destroying: true, =>
      setTimeout @props.tool.props.onDestroy, DESTROY_TRANSITION_DURATION




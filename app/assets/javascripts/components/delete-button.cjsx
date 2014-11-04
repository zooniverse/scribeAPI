# @cjsx React.DOM

React = require 'react'

DeleteButton = React.createClass
  displayName: 'DeleteButton'

  render: ->
    if @props.workflow isnt "text-region"
      return null
    fillColor = '#26baff'
    strokeColor = '#000'
    strokeWidth = 3
    radius = 15

    cross = "
      M #{-radius * 0.6 } 0
      L #{ radius * 0.6 } 0
      M 0 #{-radius * 0.6 }
      L 0 #{radius * 0.6 }
    "

    @transferPropsTo <g className="clickable drawing-tool-delete-button" stroke={strokeColor} strokeWidth={strokeWidth} onClick={@props.onClick}>
      <circle r={radius} fill={fillColor} />
      <path d={cross} transform="rotate(45)" />
    </g>

window.delete_button =

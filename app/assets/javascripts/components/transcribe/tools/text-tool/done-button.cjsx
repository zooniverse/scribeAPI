# @cjsx React.DOM
React = require 'react'

DoneButton = React.createClass
  displayName: 'DoneButton'

  render: ->
    classes = 'button done'
    title   = 'Next Entry'
    
    <button className = {classes} onClick = {@props.onClick} >
      {title}
    </button>

module.exports = DoneButton

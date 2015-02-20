# @cjsx React.DOM
React = require 'react'

DoneButton = React.createClass
  displayName: 'DoneButton'

  render: ->
    classes = 'button done'
    classes = classes + ' disabled' if @props.nextStepAvailable()
    title   = 'Next Entry'
    
    <button className = {classes} onClick = {@props.nextTextEntry} >
      {title}
    </button>

module.exports = DoneButton

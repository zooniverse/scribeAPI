# @cjsx React.DOM
React = require 'react'

DoneButton = React.createClass
  displayName: 'DoneButton'

  render: ->
    classes = 'button done'
      
    <button className = {classes} onClick = {@props.prevStep} >
      Done
    </button>

module.exports = DoneButton

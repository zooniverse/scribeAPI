# @cjsx React.DOM
React = require 'react'

PrevButton = React.createClass
  displayName: 'PrevButton'

  render: ->
    classes = 'button prev'
    classes = classes + ' disabled' unless @props.prevStepAvailable()
      
    <button className = {classes} onClick = {@props.prevStep} >
      &lt; Back
    </button>

module.exports = PrevButton

# @cjsx React.DOM
React = require 'react'

PrevButton = React.createClass
  displayName: 'PrevButton'

  render: ->
    console.log 'IS PREV STEP AVAILABLE? ', @props.prevStepAvailable()
    classes = 'button blue back'
    unless @props.prevStepAvailable()
      classes = classes + ' disabled'

    <button className = {classes} onClick = { @prevStep }>
      &lt; Back
    </button>

module.exports = PrevButton

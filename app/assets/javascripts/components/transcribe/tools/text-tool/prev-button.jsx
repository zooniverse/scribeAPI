# @cjsx React.DOM
React = require 'react'

PrevButton = React.createClass
  displayName: 'PrevButton'

  render: ->
    classes = 'button prev'
    # classes = classes + ' disabled' #unless @props.prevStepAvailable()

    <button className = {classes} onClick = {null} >
      &lt; Back
    </button>

module.exports = PrevButton

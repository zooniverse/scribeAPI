# @cjsx React.DOM
React = require 'react'

NextButton = React.createClass
  displayName: 'NextButton'

  render: ->
    classes = 'button next'
    # classes = classes + ' disabled' unless @props.nextStepAvailable()

    <button className = {classes} onClick = {null} >
      Next &gt;
    </button>

module.exports = NextButton

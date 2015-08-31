React         = require 'react'
SmallButton   = require './small-button'

module.exports = React.createClass
  displayName: 'BadSubjectButton'

  render: ->
    label = @props.label ? ( if @props.active then 'Bad Subject' else 'Bad Subject?' )

    <SmallButton label={label} onClick={@props.onClick} className="ghost toggle-button #{'toggled' if @props.active}" />

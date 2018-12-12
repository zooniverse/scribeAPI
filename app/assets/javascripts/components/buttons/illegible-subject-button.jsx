React         = require 'react'
SmallButton   = require './small-button'

module.exports = React.createClass
  displayName: 'IllegibleSubjectButton'

  render: ->
    label = if @props.active then 'Illegible' else 'Illegible?'

    <SmallButton key="illegible-subject-button" label={label} onClick={@props.onClick} className="ghost toggle-button #{'toggled' if @props.active}" />

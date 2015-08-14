React         = require 'react'
SmallButton   = require './small-button'

module.exports = React.createClass
  displayName: 'IllegibleSubjectButton'

  render: ->
    label = if @props.active then 'Illegible' else 'Illegible?'

    <SmallButton label={label} onClick={@props.onClick} className="ghost bad-subject #{'marked-bad' if @props.active}" />
     

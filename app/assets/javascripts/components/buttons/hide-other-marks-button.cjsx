React         = require 'react'
SmallButton   = require './small-button'

module.exports = React.createClass
  displayName: 'HideOtherMarksButton'

  render: ->
    label = if @props.active then 'Show Other Marks' else 'Hide Other Marks'

    <SmallButton label={label} onClick={@props.onClick} className="ghost toggle-button #{'toggled' if @props.active}" />

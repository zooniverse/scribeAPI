React         = require 'react'
SmallButton   = require './small-button'

module.exports = React.createClass
  displayName: 'HideOtherMarksButton'

  render: ->
    label = 'Hide Other Marks' #if @props.active then 'Bad Subject' else 'Hide Other Marks'

    <SmallButton label={label} onClick={@props.onClick} className="ghost toggle-button #{'toggled' if @props.active}" />

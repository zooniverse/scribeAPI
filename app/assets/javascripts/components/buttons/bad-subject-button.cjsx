React         = require 'react'
GenericButton = require './generic-button'

module.exports = React.createClass
  displayName: 'BadSubjectButton'

  render: ->
    label = if @props.active then 'Bad Subject' else 'Bad Subject?'

    <GenericButton label={label} onClick={@props.onClick} className="pill-button bad-subject #{'marked-bad' if @props.active}"/>
     

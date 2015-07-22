React         = require 'react'
GenericButton = require './generic-button'

module.exports = React.createClass
  displayName: 'DoneButton'

  getDefaultProps: ->
    label: 'Done'

  render: ->
    <GenericButton label={@props.label} onClick={@props.onClick} className='done'/>
     

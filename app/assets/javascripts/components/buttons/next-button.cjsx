React         = require 'react'
GenericButton = require './generic-button'

module.exports = React.createClass
  displayName: 'NextButton'

  getDefaultProps: ->
    label: 'Next &gt;'
 
  render: ->
    <GenericButton label={@props.label} onClick={@props.onClick} className='next'/>
     

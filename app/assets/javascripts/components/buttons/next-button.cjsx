React         = require 'react'
GenericButton = require './generic-button'

module.exports = React.createClass
  displayName: 'NextButton'

  getDefaultProps: ->
    label: 'Next &gt;'
 
  render: ->
    <MajorButton {...@props} className='next'/>
     

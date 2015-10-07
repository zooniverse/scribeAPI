React         = require 'react'
GenericButton = require './generic-button'

module.exports = React.createClass
  displayName: 'NextButton'

  getDefaultProps: ->
    label: 'Next &gt;'
 
  render: ->
    <MajorButton key="major-button" {...@props} className='next'/>
     

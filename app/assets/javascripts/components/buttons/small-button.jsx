React         = require 'react'
GenericButton = require './generic-button'

module.exports = React.createClass
  displayName: 'SmallButton'

  getDefaultProps: ->
    label: 'Next &gt;'
 
  render: ->
    classes = ['small-button']
    classes.push @props.className if @props.className?

    <GenericButton {...@props} className={classes.join ' '} />
     

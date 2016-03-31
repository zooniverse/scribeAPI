React         = require 'react'
SmallButton   = require './small-button'

module.exports = React.createClass
  displayName: 'HelpButton'

  getDefaultProps: ->
    label: 'Need some help?' 
    key: 'help-button'
 
  render: ->
    classes = ['help-button','ghost']
    classes.push @props.className if @props.className?

    <SmallButton {...@props} className={classes.join ' '} />

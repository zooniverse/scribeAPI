React             = require 'react'
TextTool          = require '../text-tool'

module.exports = React.createClass
  displayName: 'NumberTool'

  render: ->
    <TextTool {...@props} inputType='number'/>

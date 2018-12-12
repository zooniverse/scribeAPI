React             = require 'react'
TextTool          = require '../text-tool'

module.exports = React.createClass
  displayName: 'DateTool'

  render: ->
    <TextTool {...@props} inputType='date'/>

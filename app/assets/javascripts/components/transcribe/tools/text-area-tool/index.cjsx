React             = require 'react'
TextTool          = require '../text-tool'

TextAreaTool = React.createClass
  displayName: 'TextAreaTool'

  render: ->
    # Everything about a textarea-tool is identical in text-tool, so let's parameterize text-tool
    <TextTool {...@props} inputType='textarea'/>

module.exports = TextAreaTool

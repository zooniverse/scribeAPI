# @cjsx React.DOM
React           = require 'react'
Draggable       = require '../../../../lib/draggable'
DoneButton      = require './done-button'

CompositeTool = React.createClass
  displayName: 'CompositeTool'

  render: ->
    console.log "CompositeTool#render: ", @props, @props.task
    <div>
      { for annotation_key, tool_config of @props.task.tool_options.tools
        console.log "  CompositeTool#render: loading tool: ", annotation_key, tool_config
        tool_inst = require "../#{tool_config.tool.replace(/_/, '-')}/"
        console.log "  CompositeTool#render: tool: ", tool_config.tool, tool_inst
        <tool_inst {...@props} />
      }
    </div>

module.exports = CompositeTool

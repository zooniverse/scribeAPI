React = require 'react'
drawingTools = require './index'

module.exports = React.createClass
  displayName: 'AggregateMark'

  getDefaultProps: ->
    toolDefinition: null
    mark: null
    sourceMarks: null
    expanded: false

  getInitialState: ->
    expanded: @props.expanded

  render: ->
    Tool = drawingTools[@props.toolDefinition.type]
    <g className="aggregate-mark" onClick={@toggleExpanded}>
      <Tool mark={@props.mark} tool={@props.toolDefinition} disabled />
      {if @state.expanded
        <g className="source-marks">
          {for mark in @props.sourceMarks
            mark._key ?= Math.random()
            <Tool key={mark._key} mark={mark} tool={@props.toolDefinition} disabled />}
        </g>}
    </g>

  toggleExpanded: ->
    @setState expanded: not @state.expanded

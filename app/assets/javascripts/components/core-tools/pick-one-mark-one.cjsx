React = require 'react'
GenericTask = require './generic'
# Markdown = require '../../components/markdown'

NOOP = Function.prototype

icons =
  point: <svg viewBox="0 0 100 100">
    <circle className="shape" r="30" cx="50" cy="50" />
    <line className="shape" x1="50" y1="5" x2="50" y2="40" />
    <line className="shape" x1="95" y1="50" x2="60" y2="50" />
    <line className="shape" x1="50" y1="95" x2="50" y2="60" />
    <line className="shape" x1="5" y1="50" x2="40" y2="50" />
  </svg>

  line: <svg viewBox="0 0 100 100">
    <line className="shape" x1="25" y1="90" x2="75" y2="10" />
  </svg>

  rectangle: <svg viewBox="0 0 100 100">
    <rect className="shape" x="10" y="30" width="80" height="40" />
  </svg>

  polygon: <svg viewBox="0 0 100 100">
    <polyline className="shape" points="50, 5 90, 90 50, 70 5, 90 50, 5" />
  </svg>

  circle: <svg viewBox="0 0 100 100">
    <ellipse className="shape" rx="33" ry="33" cx="50" cy="50" />
  </svg>

  ellipse: <svg viewBox="0 0 100 100">
    <ellipse className="shape" rx="45" ry="25" cx="50" cy="50" transform="rotate(-30, 50, 50)" />
  </svg>


module.exports = React.createClass
  displayName: 'PickOneMarkOne'
  statics:
    # Summary: Summary

    getDefaultAnnotation: ->
      _toolIndex: 0
      value: []

  getDefaultProps: ->
    # task: null
    # annotation: null
    onChange: NOOP

  componentDidMount: ->
    # @setState subToolIndex: 0
    # @handleChange 0
    # @setSubToolIndex @props.annotation?.subToolIndex ? 0

  componentWillReceiveProps: (new_props) ->
    # if ! new_props.annotation?.subToolIndex
      # console.log ".. set subToolIndex to 0", @state.annotation
      # @props.onChange? @state.annotation
      
    # @state.annotation
    # @handleChange 0 

  getInitialState: ->
    subToolIndex: 0 # @props.annotation?.subToolIndex ? 0
    # annotation: $.extend({subToolIndex: null}, @props.annotation ? {})

  render: ->
    # console.log "PickOneMarkOne rendering: ", @getSubToolIndex()

    tools = for tool, i in @props.task.tool_config.tools
      tool._key ?= Math.random()

      # TODO: fix count:
      count = 1 # (true for mark in @props.annotation.value when mark.tool is i).length

      <label
        key={tool._key}
        className="answer #{if i is @getSubToolIndex() then 'active' else ''}"
      >
        <span
          className="drawing-tool-icon"
          style={color: tool.color}>{icons[tool.type]}
        </span>{' '}

        <input
          type="radio"
          className="drawing-tool-input"
          checked={ i is @getSubToolIndex() }
          ref={"inp-" + i}
          onChange={ @handleChange.bind this, i }
        />

        <span>
          {tool.label}
        </span>


      </label>

    # tools = null if tools.length == 1

    <GenericTask question={@props.task.instruction} onBadSubject={@props.onBadSubject} onShowHelp={@props.onShowHelp} answers={tools} />

  getSubToolIndex: ->
    @state.subToolIndex

  setSubToolIndex: (index) ->
    @setState subToolIndex: index, () =>
      @props.onChange? subToolIndex: index

  handleChange: (index, e) ->
    # console.log 'PICK-ONE-MARK-ONE::handleChange(), INDEX = ', index, @refs
    inp = @refs["inp-#{index}"]
    if inp.getDOMNode().checked
      @setSubToolIndex index


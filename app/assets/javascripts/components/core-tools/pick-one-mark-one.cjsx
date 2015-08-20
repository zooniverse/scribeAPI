React = require 'react'
GenericTask = require './generic'
# Markdown = require '../../components/markdown'

NOOP = Function.prototype

icons =
  pointTool: <svg viewBox="0 0 100 100">
    <circle className="shape" r="30" cx="50" cy="50" />
    <line className="shape" x1="50" y1="5" x2="50" y2="40" />
    <line className="shape" x1="95" y1="50" x2="60" y2="50" />
    <line className="shape" x1="50" y1="95" x2="50" y2="60" />
    <line className="shape" x1="5" y1="50" x2="40" y2="50" />
  </svg>

  line: <svg viewBox="0 0 100 100">
    <line className="shape" x1="25" y1="90" x2="75" y2="10" />
  </svg>

  rectangleTool: <svg viewBox="0 0 100 100">
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
  componentWillUnmount:->
    @setState
      subToolIndex: 0
      tool: @props.task?.tool_config.options[0]
    # Ensure mark/index subToolIndex is set to 0 in case next task uses a pick-one-*
    @props.onChange? subToolIndex: 0

  getInitialState: ->
    subToolIndex: 0 # @props.annotation?.subToolIndex ? 0
    tool: @props.task?.tool_config.options[0]

    # annotation: $.extend({subToolIndex: null}, @props.annotation ? {})

  render: ->
    # console.log "PickOneMarkOne rendering: ", @getSubToolIndex()

    # Calculate number of existing marks for each tool instance:
    counts = {}
    for subject in @props.subject.child_subjects
      counts[subject.type] ?= 0
      counts[subject.type] += 1

    tools = for tool, i in @props.task.tool_config.options
      tool._key ?= Math.random()

      # How many prev marks? (i.e. child_subjects with same generates_subject_type)
      count = counts[tool.generates_subject_type] ? 0
      classes = ['answer']
      classes.push 'active' if i is @getSubToolIndex()
      classes.push 'has-help' if tool.help

      <label
        key={tool._key}
        className="#{classes.join ' '}"
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
          tool={tool}
          onChange={ @handleChange.bind this, i }
        />

        <span>
          {tool.label}
          {if count
            <span className="count">{count}</span>
          }
        </span>

        {if tool.help
          <span className="help" data-text="#{tool.help}"><i className="fa fa-question"></i></span>
        }

      </label>

    # tools = null if tools.length == 1

    <GenericTask question={@props.task.instruction} onBadSubject={@props.onBadSubject} onShowHelp={@props.onShowHelp} answers={tools} />

  getSubToolIndex: ->
    @state.subToolIndex

  updateState: (data) ->
    @setState data, () =>
      @props.onChange? data

  handleChange: (index, e) ->
    # console.log 'PICK-ONE-MARK-ONE::handleChange(), INDEX = ', index, @refs
    inp = @refs["inp-#{index}"]
    if inp.getDOMNode().checked
      @updateState
        subToolIndex: index
        tool: inp.props.tool

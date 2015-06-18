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

# Summary = React.createClass
#   displayName: 'SingleChoiceSummary'

#   getDefaultProps: ->
#     task: null
#     annotation: null
#     expanded: false

#   getInitialState: ->
#     expanded: @props.expanded

#   render: ->
#     <div className="classification-task-summary">
#       <div className="question">
#         {@props.task.instruction}
#         {if @state.expanded
#           <button type="button" className="toggle-more" onClick={@setState.bind this, expanded: false, null}>Less</button>
#         else
#           <button type="button" className="toggle-more" onClick={@setState.bind this, expanded: true, null}>More</button>}
#         {if @props.onToggle?
#           if @props.inactive
#             <button type="button"><i className="fa fa-eye fa-fw"></i></button>
#           else
#             <button type="button"><i className="fa fa-eye-slash fa-fw"></i></button>}
#       </div>

#       {for tool, i in @props.task.tools
#         tool._key ?= Math.random()
#         toolMarks = (mark for mark in @props.annotation.value when mark.tool is i)
#         if @state.expanded or toolMarks.length isnt 0
#           <div key={tool._key} className="answer">
#             {tool.type} <strong>{tool.label}</strong> ({[].concat toolMarks.length})
#             {if @state.expanded
#               for mark, i in toolMarks
#                 mark._key ?= Math.random()
#                 <div key={mark._key}>
#                   {i + 1}){' '}
#                   {for key, value of mark when key not in ['tool', 'sources'] and key.charAt(0) isnt '_'
#                     <code key={key}><strong>{key}</strong>: {JSON.stringify value}&emsp;</code>}
#                 </div>}
#           </div>}
#     </div>

module.exports = React.createClass
  displayName: 'PickOneMarkOne'
  statics:
    # Summary: Summary

    getDefaultAnnotation: ->
      _toolIndex: 0
      value: []

  getDefaultProps: ->
    task: null
    annotation: null
    onChange: NOOP

  componentDidMount: ->
    # @setState subToolIndex: 0
    # @handleChange 0
    @setSubToolIndex 0

  componentWillReceiveProps: (new_props) ->
    # @setSubToolIndex 0
    console.log "set subToolIndex to 0", new_props
    # @state.annotation
    # @handleChange 0 

  getInitialState: ->
    subToolIndex: @props.annotation?.subToolIndex ? 0
    annotation: $.extend({subToolIndex: null}, @props.annotation ? {})

  render: ->
    tools = for tool, i in @props.task.tool_config.tools
      tool._key ?= Math.random()

      # TODO: fix count:
      count = 1 # (true for mark in @props.annotation.value when mark.tool is i).length

      <label
        key={tool._key}
        className="minor-button #{if i is @getSubToolIndex() then 'active' else ''}"
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

    <GenericTask question={@props.task.instruction} help={@props.task.help} answers={tools} />

  getSubToolIndex: ->
    @props.annotation?.subToolIndex ? 0

  setSubToolIndex: (index) ->
    annotation = @state.annotation
    annotation.subToolIndex = index
    annotation.toolName = @props.task.tool_config.tools[index].type
    annotation.subToolIndex = index
    @setState
      annotation: annotation, () =>
        console.log "updating cnn: ", @state.annotation
        @props.onChange? @state.annotation

  handleChange: (index, e) ->
    console.log 'handleChange(): INDEX = ', index, @refs
    inp = @refs["inp-#{index}"]
    if inp.getDOMNode().checked
      @setSubToolIndex index

      # if e.target.checked
      # @props.onChange? {
        # subToolIndex: index,
        # toolName: @props.task.tool_config.tools[index].type
        # generates_subject_type: @props.task.tool_config.tools[index].generates_subject_type
      # }

      # @forceUpdate()

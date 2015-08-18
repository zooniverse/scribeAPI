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
  displayName: 'PickMany'
  statics:
    # Summary: Summary

    getDefaultAnnotation: ->
      _toolIndex: 0
      value: []

  getDefaultProps: ->
    task: null
    onChange: NOOP

  getInitialState: ->
    annotation: [] #@props.annotation ? {}

  render: ->

    console.log 'PROPS:>>>>>>>>>>>>>>>> ', @props
    options = for option, i in @props.task.tool_config.options
      option._key ?= Math.random()
      isChecked = option.value in @state.annotation

      <label
        key={option._key}
        className="answer minor-button #{if isChecked then 'active' else ''}"
      >
        <span
          className='drawing-tool-icon'
          style={color: option.color}>{icons[option.value]}
        </span>{' '}

        <input
          type='checkbox'
          className='drawing-tool-input'
          checked={isChecked}
          ref={'inp-' + i}
          onChange={ @handleChange.bind this, i }
        />
        <span>
          {option.label}
        </span>

        {if option.help?
          <span className="help" data-text="#{option.help}"><i className="fa fa-question"></i></span>
        }

      </label>

    <GenericTask question={@props.task.instruction} onShowHelp={@props.onShowHelp} answers={options} />

  handleChange: (index, e) ->

    inp = @refs["inp-#{index}"]
    annotation = @state.annotation
    value = @props.task.tool_config.options[index].value
    isChecked = annotation.indexOf(value) >= 0

    # toggle checkmark
    if isChecked
      annotation.splice(annotation.indexOf(value), 1) # remove entry
    else
      annotation.push value

    @setState
      annotation: annotation, () =>
        @props.onChange? annotation

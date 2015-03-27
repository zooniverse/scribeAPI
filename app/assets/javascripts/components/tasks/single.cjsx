React = require 'react'
GenericTask = require './generic'
# Markdown = require '../../components/markdown'

NOOP = Function.prototype

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
#         {@props.task.question}
#         {if @state.expanded
#           <button type="button" className="toggle-more" onClick={@setState.bind this, expanded: false, null}>Less</button>
#         else
#           <button type="button" className="toggle-more" onClick={@setState.bind this, expanded: true, null}>More</button>}
#       </div>
#       <div className="answers">
#         {if @state.expanded
#           for answer, i in @props.task.answers
#             answer._key ?= Math.random()
#             <div key={answer._key} className="answer">
#               {if i is @props.annotation.value
#                 <i className="fa fa-check-circle-o fa-fw"></i>
#               else
#                 <i className="fa fa-circle-o fa-fw"></i>}
#               {@props.task.answers[i].label}
#             </div>
#         else if @props.annotation.value?
#           <div className="answer">
#             <i className="fa fa-check-circle-o fa-fw"></i>
#             {@props.task.answers[@props.annotation.value].label}
#           </div>
#         else
#           <div className="answer">No answer</div>}
#       </div>
#     </div>

module.exports = React.createClass
  displayName: 'SingleChoiceTask'

  statics:
    # Summary: Summary # don't use Summary (yet?)

    getDefaultAnnotation: ->
      value: null

  getDefaultProps: ->
    task: null
    annotation: null
    onChange: NOOP

  render: ->
    console.log 'CURRENT ANNOTATION: ', @props.annotation
    answers = for i, answer of @props.task.options
      answer._key ?= Math.random()
      <label key={answer._key} className="minor-button">
        <input type="radio" checked={i is @props.annotation?.value} onChange={@handleChange.bind this, i} />
        <span>{answer.label}</span>
      </label>

    <GenericTask question={@props.task.instruction} help={@props.task.help} answers={answers} />

  handleChange: (index, e) ->
    if e.target.checked
      @props.annotation.value = index
      @props.onChange index
      @forceUpdate() # update the radiobuttons after selection


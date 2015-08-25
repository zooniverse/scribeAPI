React                   = require 'react'
GenericTask             = require './generic'
LabeledRadioButton      = require 'components/buttons/labeled-radio-button'

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

  propTypes: ->
    task: React.PropTypes.object.isRequired
    annotation: React.PropTypes.object.isRequired
    onChange: React.PropTypes.func.isRequired

  render: ->
    answers = for answer in @props.task.tool_config.options
      answer._key ?= Math.random()
      checked = answer.value is @props.annotation.value
      classes = ['minor-button']
      classes.push 'active' if checked

      <LabeledRadioButton key={answer._key} classes={classes.join ' '} value={answer.value} checked={checked} onChange={@handleChange.bind this, answer.value} label={answer.label} />

    <GenericTask ref="inputs" {...@props} question={@props.task.instruction} answers={answers} />

  handleChange: (index, e) ->
    if e.target.checked
      @props.onChange({
        value: e.target.value
      })
      @forceUpdate() # update the radiobuttons after selection

window.React = React

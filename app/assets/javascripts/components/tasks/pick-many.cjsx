React = require 'react'
GenericTask = require './generic'

NOOP = Function.prototype

module.exports = React.createClass
  displayName: 'MultipleChoiceTask'

  statics:
    getDefaultAnnotation: ->
      value: null

  getDefaultProps: ->
    task: null
    annotation: null
    onChange: NOOP

  render: ->
    answers = for i, answer of @props.task.options
      answer._key ?= Math.random()
      <label key={answer._key} className="minor-button" onClick={@props.onChange.bind this, i}>
        <span>{answer.label}</span>
      </label>
    <GenericTask question={@props.task.instruction} help={@props.task.help} answers={answers} />

  handleChange: (index, e) ->
    if e.target.checked
      @props.annotation.value = index
      @props.onChange index
      @forceUpdate() # update the radiobuttons after selection


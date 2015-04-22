React = require 'react'
core_tools        = require './index'
transcribe_tools   = require '../transcribe/tools'

NOOP = Function.prototype

module.exports = React.createClass
  displayName: 'SwitchOnValueTask'

  getDefaultProps: ->
    task: null
    annotation: null
    workflow: null
    onChange: NOOP

  render: ->
    field = @props.task.tool_options.field
    field_value = @props.annotation[field]
    console.log "SwitchOnValue#render: getting matched_option #{@props.task.tool_options.field} from annotation:", @props.annotation
    matched_option = @props.task.tool_options.options[field_value]
    if ! matched_option?
      console.log "WARN: SwitchOnValueTask can't find matching task \"#{field_value}\" in", @props.task.tool_options.options
      return null

    else
      task = @props.workflow.tasks[matched_option.task]
      console.log "load task: ", task
      TaskComponent = core_tools[task.tool] ? transcribe_tools[task.tool]
      console.log "load tool: ", TaskComponent
      <TaskComponent task={task} annotation={@props.annotation} onChange={@handleTaskComponentChange} workflow={@props.workflow}/>

  handleChange: (index, e) ->
    if e.target.checked
      @props.annotation.value = index
      @props.onChange index
      @forceUpdate() # update the radiobuttons after selection


React                   = require 'react'

module.exports = React.createClass # rename to Classifier
  displayName: 'ProgressBar'

  getDefaultProps: ->
    steps: []

  getInitialState: ->
    currentTask: @props.currentTask
    currentStep: @props.workflow.first_task

  componentWillReceiveProps: (newProps) ->
    @props.previousTask = @state.currentTask

    currentStep = @state.currentStep
    if newProps.currentTask.key in @props.steps
      currentStep = newProps.currentTask.key

    @setState
      currentTask: newProps.currentTask
      currentStep: currentStep
      previousTask: @props.currentTask, =>
        @forceUpdate()

  componentWillMount: ->
    @extractSequentialTasks()

  extractSequentialTasks: ->
    # traverse each task in order. if label present, then add to steps (label not implemented yet)
    tasks = @props.workflow.tasks
    key = @props.workflow.first_task
    while key isnt null
      # if tasks[key].label? then @props.steps.push tasks[key].label
      # console.log 'CURRENT TASK: ', tasks[key]
      @props.steps.push key
      key = tasks[key].next_task # advance to next key

    # console.log 'PROGRESS BAR STEPS: ', @props.steps

  render: ->

    # previous_task_key = @state.previousTask?.key
    # # DEBUG CODE
    # console.log '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    # console.log '  > CURRENT TASK : ', current_task_key
    # console.log '  > PREVIOUS TASK: ', previous_task_key
    # console.log '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'

    <div className="progress-bar">
      <p>Progress</p>
      <ol>
        { for step in @props.steps
            if step is @state.currentStep then classes = 'active'
            else classes = ''
            <li className={classes}>{step}</li>
        }
      </ol>

    </div>

window.React = React

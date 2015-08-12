React                   = require 'react'

module.exports = React.createClass # rename to Classifier
  displayName: 'ProgressBar'

  # getInitialState: ->

  # componentWillReceiveProps: ->
  #   console.log 'componentWillReceiveProps(), PROPS: ', @props

  getDefaultProps: ->
    steps: []

  componentWillMount: ->
    @extractSequentialTasks()

  extractSequentialTasks: ->
    # traverse each task in order. if label present, then add to steps
    tasks = @props.workflow.tasks
    key = @props.workflow.first_task
    while key isnt null
      # if tasks[key].label? then @props.steps.push tasks[key].label
      # console.log 'CURRENT TASK: ', tasks[key]
      @props.steps.push key
      key = tasks[key].next_task # advance to next key

    console.log 'STEPS: ', @props.steps

  render: ->
    console.log 'componentWillMount(): Current Active Workflow: ', @props.workflow
    console.log 'CURRENT TASK: ', @props.currentTask

    current_task_key = @props.currentTask.key

    <div className="progress-bar">
      <p>Progress</p>
      <ol>
        { for step in @props.steps
            if step is current_task_key
              classes = 'active'
            else
              classes = ''
            console.log 'ACTIVE: ', step
            <li className={classes}>{step}</li>
        }

      </ol>

    </div>

window.React = React

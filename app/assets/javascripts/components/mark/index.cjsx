# @cjsx React.DOM
React         = require 'react'
SubjectViewer = require '../subject-viewer'
tasks         = require '../tasks'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'

  propTypes:
    workflow: React.PropTypes.object.isRequired

  getInitialState: ->
    workflow: @props.workflow
    firstTask: true
    currentTask: null
    # currentTool: null

  componentWillMount: ->
    workflow = @state.workflow
    @setState currentTask:  @state.workflow.tasks[workflow.first_task]


  componentDidMount: ->
    console.log 'CURRENT TASK: ', @state.currentTask.tool
    
  render: ->
    console.log 'taskType: ', @state.taskType
    TaskComponent = tasks[@state.currentTask.tool]
    
    <div>
      <SubjectViewer
        endpoint={"/workflows/#{@state.workflow.id}/subjects.json?limit=5"}
        workflow={@props.workflow}
      />
      <TaskComponent task={@state.currentTask} annotation={null} onChange={null} />
    </div>

window.React = React

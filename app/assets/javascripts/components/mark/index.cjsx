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
    
    <div className="classifier">
      <div className="subject-area">
        <SubjectViewer
          endpoint={"/workflows/#{@state.workflow.id}/subjects.json?limit=5"}
          workflow={@props.workflow}
        />
      </div>
      <div className="task-area">
        <div className="task-container">
          <TaskComponent task={@state.currentTask} annotation={null} onChange={null} />
          <hr/>
          <nav className="task-nav">
            <button type="button" className="back minor-button" disabled={false}>Back</button>
            { if nextTaskKey?
                <button type="button" className="continue major-button" disabled={false} onClick={null}>Next</button>
              else
                <button type="button" className="continue major-button" disabled={false} onClick={null}>Done</button>
            }
          </nav>
        </div>
      </div>
    </div>

window.React = React

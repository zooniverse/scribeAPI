React              = require 'react'
SubjectViewer      = require '../subject-viewer'
tasks              = require '../tasks'
FetchSubjectsMixin = require 'lib/fetch-subjects-mixin'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'
  
  propTypes:
    workflow: React.PropTypes.object.isRequired
  
  mixins: [FetchSubjectsMixin] # sets state variables: subjects, currentSubject, classification

  getInitialState: ->
    subjects:       null
    currentSubject: null
    classification: null
    workflow:       @props.workflow
    currentTask:    @props.workflow.tasks[@props.workflow.first_task]

  render: ->
    return null unless @state.currentSubject?
    TaskComponent = tasks[@state.currentTask.tool]

    console.log '@state.currentTask: ', @state.currentTask
    
    <div className="classifier">
      <div className="subject-area">
        <SubjectViewer subject={@state.currentSubject} />
      </div>
      <div className="task-area">
        <div className="task-container">
          <TaskComponent task={@state.currentTask} annotation={null} onChange={null} />
          <hr/>
          <nav className="task-nav">
            <button type="button" className="back minor-button" disabled={false}>Back</button>
            { if @state.currentTask.next_task?
                <button type="button" className="continue major-button" disabled={false} onClick={null}>Next</button>
              else
                <button type="button" className="continue major-button" disabled={false} onClick={null}>Done</button>
            }
          </nav>
        </div>
      </div>
    </div>

window.React = React

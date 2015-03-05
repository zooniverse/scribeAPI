# @cjsx React.DOM
React              = require 'react'
SubjectViewer      = require '../subject-viewer'
tasks              = require '../tasks'
Classification     = require 'models/classification'
FetchSubjectsMixin = require 'lib/fetch-subjects-mixin'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'
  
  propTypes:
    workflow: React.PropTypes.object.isRequired
  
  mixins: [FetchSubjectsMixin]

  getInitialState: ->
    subjects: null
    currentSubject: null
    workflow:       @props.workflow
    currentTask:    @props.workflow.tasks[@props.workflow.first_task]
    # classification: new Classification subject
    
  render: ->
    return null unless @state.currentSubject?
    TaskComponent = tasks[@state.currentTask.tool]
    
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

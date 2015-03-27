React              = require 'react'
SubjectViewer      = require '../subject-viewer'
tasks              = require '../tasks'
FetchSubjectsMixin = require 'lib/fetch-subjects-mixin'
JSONAPIClient      = require 'json-api-client' # use to manage data?

resource = new JSONAPIClient

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'
  
  propTypes:
    workflow: React.PropTypes.object.isRequired
  
  mixins: [FetchSubjectsMixin] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    subjects:       null
    currentSubject: null
    workflow:       @props.workflow
    currentTask:    @props.workflow.tasks[@props.workflow.first_task]

  getDefaultProps: ->
    classification: resource.type('classifications').create
      annotations: []
      metadata: {}

  componentWillMount: ->
    @addAnnotationForTask @props.workflow.first_task

  render: ->
    return null unless @state.currentSubject? and @state.currentTask?
    TaskComponent = tasks[@state.currentTask.tool]
    onFirstAnnotation = @props.classification.annotations.length is 0

    annotations = @props.classification.annotations
    currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]

    waitingForAnswer = false # for now 

    <div className="classifier">
      <div className="subject-area">
        <SubjectViewer subject={@state.currentSubject} />
      </div>
      <div className="task-area">
        <div className="task-container">
          <TaskComponent task={@state.currentTask} annotation={currentAnnotation} onChange={=> @props.classification.update 'annotation'} />
          <hr/>
          <nav className="task-nav">
            <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@prevTask}>Back</button>
            { if @state.currentTask.next_task?
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@addAnnotationForTask.bind this, @state.currentTask.next_task}>Next</button>
              else
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@completeClassification}>Done</button>
            }
          </nav>
        </div>
      </div>
    </div>

  nextTask: ->
    return unless @state.currentTask.next_task?
    @setState 
      currentTask: @state.workflow.tasks[ @state.currentTask.next_task ]

  prevTask: ->
    console.log 'prevTask()'

  destroyCurrentAnnotation: ->
    @props.classification.annotations.pop()
    @props.classification.update 'annotations'

  addAnnotationForTask: (taskKey) ->
    taskDescription = @props.workflow.tasks[taskKey]
    annotation = tasks[taskDescription.tool].getDefaultAnnotation() # sets {value: null}
    annotation.task = taskKey # e.g. {task: "cool"}
    @props.classification.annotations.push annotation
    @props.classification.update 'annotations'

  completeClassification: ->
    @props.classification.update
      completed: true
      # 'metadata.finished_at': (new Date).toISOString()
    # @props.onComplete?()

window.React = React

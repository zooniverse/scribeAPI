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
      name: 'Classification'
      annotations: []
      metadata: {}

  componentWillMount: ->
    @addAnnotationForTask @props.workflow.first_task

  render: ->
    return null unless @state.currentSubject?

    annotations = @props.classification.annotations
    currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]
    currentTask = @props.workflow.tasks[currentAnnotation?.task]

    TaskComponent = tasks[currentTask.tool]

    onFirstAnnotation = currentAnnotation?.task is @props.workflow.first_task

    if currentTask.type is 'single'
      currentAnswer = currentTask.options?[currentAnnotation.value]
      waitingForAnswer = not currentAnswer

    <div className="classifier">
      <div className="subject-area">
        <SubjectViewer subject={@state.currentSubject} workflow={@props.workflow} classification={@props.classification} annotation={currentAnnotation} />
      </div>
      <div className="task-area">
        <div className="task-container">
          <TaskComponent task={currentTask} annotation={currentAnnotation} onChange={@handleTaskComponentChange} />
          <hr/>
          <nav className="task-nav">
            <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
            { if currentTask.next_task?
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@addAnnotationForTask.bind this, currentTask.next_task}>Next</button>
              else
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@completeClassification}>Done</button>
            }
          </nav>
        </div>
      </div>
    </div>

  handleTaskComponentChange: ->
    @props.classification.update 'annotation'

  destroyCurrentAnnotation: ->
    @props.classification.annotations.pop()
    @props.classification.update 'annotations'
    @forceUpdate()

  addAnnotationForTask: (taskKey) ->
    taskDescription = @props.workflow.tasks[taskKey]
    annotation = tasks[taskDescription.tool].getDefaultAnnotation() # sets {value: null}
    annotation.task = taskKey # e.g. {task: "cool"}
    @props.classification.annotations.push annotation
    @props.classification.update 'annotations'
    @forceUpdate()

  completeClassification: ->
    @props.classification.update
      completed: true
      'metadata.finished_at': (new Date).toISOString()
    @props.onComplete?()
    console.log 'CLASSIFICATION: ', @props.classification

window.React = React

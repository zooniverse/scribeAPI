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
    # classification: null # move to props
    workflow:       @props.workflow
    currentTask:    @props.workflow.tasks[@props.workflow.first_task]

    # # @state.classification.annotations ?= []
    # if @state.classification.annotations.length is 0
    #   console.log 'making first annotation'
    #   @makeAnnotation @state.workflow.first_task

  getDefaultProps: ->
    classification: resource.type('classifications').create
      annotations: []
      metadata: {}

  componentWillMount: ->
    console.log 'componentWillMount()'
    @addAnnotationForTask @props.workflow.first_task



  componentDidMount: ->
    console.log 'This is the componentDidMount method()'

  render: ->
    console.log 'BLAH: ', @props.classification
    return null unless @state.currentSubject? and @state.currentTask?
    TaskComponent = tasks[@state.currentTask.tool]
    onFirstAnnotation = @props.classification.annotations.length is 0

    annotations = @props.classification.annotations
    currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]

    console.log 'currentAnnotation? : ', currentAnnotation

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
    console.log '*** ADD ANNOTATION FOR TASK ***'
    console.log 'taskKey: ', taskKey
    taskDescription = @props.workflow.tasks[taskKey]
    console.log 'taskDescription: ', taskDescription
    annotation = tasks[taskDescription.tool].getDefaultAnnotation() # sets {value: null}
    annotation.task = taskKey # e.g. {task: "cool"}
    console.log 'ANNOTATION: ', annotation 
    console.log 'TASK DESCRIPTION: ', taskDescription
    @props.classification.annotations.push annotation
    @props.classification.update 'annotations'
    console.log 'CLASSIFICATION: ', @props.classification

  completeClassification: ->
    @props.classification.update
      completed: true
      # 'metadata.finished_at': (new Date).toISOString()
    # @props.onComplete?()

  # makeAnnotation: (taskKey) ->
  #   console.log 'makeAnnotation()'
  #   # taskDescription = @state.workflow.tasks[taskKey]
  #   annotation = tasks[@state.currentTask.tool].getDefaultAnnotation()
  #   annotation.tool = @state.currentTask.tool

  #   console.log 'ADDING ANNOTATION: ', annotation

  #   classification  = @props.classification 
  #   classification.annotations.push annotation

  #   @setState classification: classification, =>
  #     console.log 'CLASSIFICATION UPDATED: ', @props.classification
  #   @nextTask()

  # finishClassification: ->
  #   @makeAnnotation()
  #   console.log 'CLASSIFICATION DONE!'

  # # this is called when user clicks on radio button
  # onTaskComponentChange: (value) ->
  #   # console.log 'onTaskComponentChange() ', value

  #   classification = @props.classification
  #   annotations = classification.annotations
  #   currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]

  #   currentAnnotation.value = value

  #   console.log 'currentAnnotation ********: ', currentAnnotation
  #   # @makeAnnotation()

  #   # annotations = @props.classification.annotations
  #   # console.log 'CUCLKJDHKSLDJ: ', @state
  #   # annotations[annotations.length-1].value = value

  #   # @setState classification: classification, => console.log 'UPDATED CLASSIFICATOIN ', @props.classification

    



window.React = React

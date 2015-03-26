React              = require 'react'
SubjectViewer      = require '../subject-viewer'
tasks              = require '../tasks'
FetchSubjectsMixin = require 'lib/fetch-subjects-mixin'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'
  
  propTypes:
    workflow: React.PropTypes.object.isRequired
  
  mixins: [FetchSubjectsMixin] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    subjects:       null
    currentSubject: null
    classification: null
    workflow:       @props.workflow
    currentTask:    @props.workflow.tasks[@props.workflow.first_task]

    # # @state.classification.annotations ?= []
    # if @state.classification.annotations.length is 0
    #   console.log 'making first annotation'
    #   @makeAnnotation @state.workflow.first_task

  componentDidMount: ->
    console.log 'This is the componentDidMount method()'

  render: ->
    console.log 'BLAH: ', @state.classification
    return null unless @state.currentSubject? and @state.currentTask?
    TaskComponent = tasks[@state.currentTask.tool]
    onFirstAnnotation = @state.classification.annotations.length is 0

    annotations = @state.classification.annotations
    currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]

    console.log 'currentAnnotation? : ', currentAnnotation

    waitingForAnswer = false # for now 

    <div className="classifier">
      <div className="subject-area">
        <SubjectViewer subject={@state.currentSubject} />
      </div>
      <div className="task-area">
        <div className="task-container">
          <TaskComponent task={@state.currentTask} annotation={currentAnnotation} onChange={@onTaskComponentChange} />
          <hr/>
          <nav className="task-nav">
            <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@prevTask}>Back</button>
            { if @state.currentTask.next_task?
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@makeAnnotation}>Next</button>
              else
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@finishClassification}>Done</button>
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

  makeAnnotation: (taskKey) ->
    console.log 'makeAnnotation()'
    # taskDescription = @state.workflow.tasks[taskKey]
    annotation = tasks[@state.currentTask.tool].getDefaultAnnotation()
    annotation.tool = @state.currentTask.tool

    console.log 'ADDING ANNOTATION: ', annotation

    classification  = @state.classification 
    classification.annotations.push annotation

    @setState classification: classification, =>
      console.log 'CLASSIFICATION UPDATED: ', @state.classification
    @nextTask()

  finishClassification: ->
    @makeAnnotation()
    console.log 'CLASSIFICATION DONE!'

  # this is called when user clicks on radio button
  onTaskComponentChange: (value) ->
    # console.log 'onTaskComponentChange() ', value

    classification = @state.classification
    annotations = classification.annotations
    currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]

    currentAnnotation.value = value

    console.log 'currentAnnotation ********: ', currentAnnotation
    # @makeAnnotation()

    # annotations = @state.classification.annotations
    # console.log 'CUCLKJDHKSLDJ: ', @state
    # annotations[annotations.length-1].value = value

    # @setState classification: classification, => console.log 'UPDATED CLASSIFICATOIN ', @state.classification

    



window.React = React

React                   = require 'react'
SubjectSetViewer        = require '../subject-set-viewer'
coreTools               = require 'components/core-tools'
FetchSubjectSetsMixin   = require 'lib/fetch-subject-sets-mixin'
JSONAPIClient           = require 'json-api-client' # use to manage data?
ForumSubjectWidget      = require '../forum-subject-widget'

API                     = require '../../lib/api'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'

  propTypes:
    workflow: React.PropTypes.object.isRequired

  mixins: [FetchSubjectSetsMixin] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    subjects:       null
    currentSubjectSet: null
    workflow:       @props.workflow
    project:        @props.project
    currentTask:    @props.workflow.tasks[@props.workflow.first_task]

  getDefaultProps: ->
    classification: API.type('classifications').create
      name: 'Classification'
      annotations: [] # TODO: REMOVE
      annotation: ''
      metadata: {}
      'metadata.started_at': (new Date).toISOString()

  componentWillMount: ->
    @addAnnotationForTask @props.workflow.first_task

  render: ->
    return null unless @state.currentSubjectSet?

    # annotations = @props.classification.annotations
    # currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]
    currentAnnotation = @props.classification.annotation

    console.log 'CURRENT ANNOTATION: ', currentAnnotation

    
    currentTask = @props.workflow.tasks[currentAnnotation?.task]
    TaskComponent = coreTools[currentTask.tool]
    onFirstAnnotation = currentAnnotation?.task is @props.workflow.first_task

    nextTask = if currentTask.options?[currentAnnotation.value]?
      currentTask.options?[currentAnnotation.value].next_task
    else
      currentTask.next_task

    if currentTask.tool is 'pick_one'
      currentAnswer = currentTask.options?[currentAnnotation.value]
      waitingForAnswer = not currentAnswer

    <div className="classifier">
      <div className="subject-area">
        { if @state.noMoreSubjectSets
            style = marginTop: "50px"
            <p style={style}>There is nothing left to do. Thanks for your work and please check back soon!</p>
          else if @state.currentSubjectSet?
            <SubjectSetViewer subject_set={@state.currentSubjectSet} workflow={@props.workflow} classification={@props.classification} annotation={currentAnnotation} />
        }
      </div>
      <div className="task-area">
        <div className="task-container">
          <TaskComponent task={currentTask} annotation={currentAnnotation} onChange={@handleTaskComponentChange} />
          <hr/>
          <nav className="task-nav">
            <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
            { if nextTask?
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@loadNextTask nextTask}>Next</button>
              else
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@completeClassification}>Done</button>
            }
          </nav>
        </div>

        <div className="forum-holder">
          <ForumSubjectWidget subject_set=@state.currentSubjectSet />
        </div>

      </div>
    </div>


  handleTaskComponentChange: ->
    @updateAnnotations()

  updateAnnotations: ->
    # DEBUG CODE
    # console.log 'UPDATE ANNOTATIONS'
    @props.classification.update 'annotations'
      # annotations: @props.classification.annotations
    @forceUpdate()

  destroyCurrentAnnotation: ->
    @props.classification.annotations.pop()
    @updateAnnotations()

  addAnnotationForTask: (taskKey) ->
    console.log 'addAnnotationForTask(): TASKS: ', @props.workflow.tasks
    taskDescription = @props.workflow.tasks[taskKey]
    console.log "ERROR: Invalid tool: #{taskDescription.tool}. Available tools are: #{(k for k,v of coreTools)}" if ! coreTools[taskDescription.tool]?
    annotation = coreTools[taskDescription.tool].getDefaultAnnotation() # sets {value: null}
    annotation.task = taskKey # e.g. {task: "cool"}
    # @props.classification.annotations.push annotation
    @props.classification.annotation = annotation

    console.log 'annotation: ', annotation
    @updateAnnotations()

  loadNextTask: (nextTask) ->
    if nextTask is null
      console.log 'NOTHING LEFT TO DO'
      return
    console.log 'LOADING NEXT TASK: ', nextTask
    @addAnnotationForTask.bind this, nextTask

  completeClassification: ->
    # TODO: PB This doesn't post subject_id, which is required for classification model
    # Because we're requiring a single classification to be saved for each mark created, I don't think this method makes sense as written anymore
    # Rather than create a classification, it should probably ask the user if there's anything more to mark on the currently viewed subject, and inc subject.retire_count accordingly
    console.log "TODO: At this point, ask user if there's more to mark and then load next subjectset to classify."
    return
    @props.classification.update
      completed: true
      subject_set: @state.currentSubjectSet
      workflow_id: @state.workflow.id
      console.log "Gen NEw SUB", @state.workflow.generates_new_subjects
      'metadata.finished_at': (new Date).toISOString()
    @props.classification.save()
    @props.onComplete?() # does this do anything? -STI
    console.log 'CLASSIFICATION: ', @props.classification

window.React = React

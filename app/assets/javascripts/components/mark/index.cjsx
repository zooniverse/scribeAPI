React                   = require 'react'
SubjectSetViewer        = require '../subject-set-viewer'
coreTools               = require 'components/core-tools'
FetchSubjectSetsMixin   = require 'lib/fetch-subject-sets-mixin'
JSONAPIClient           = require 'json-api-client' # use to manage data?
ForumSubjectWidget      = require '../forum-subject-widget'

Classification          = require 'models/classification.coffee'

API                     = require '../../lib/api'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'

  propTypes:
    workflow: React.PropTypes.object.isRequired

  mixins: [FetchSubjectSetsMixin] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    subjects:       null
    currentSubjectSet: null
    currentSubject: null
    workflow:       @props.workflow
    project:        @props.project
    currentTask:    @props.workflow.tasks[@props.workflow.first_task]
    subToolIndex: 0
    taskKey: null
    annotation: {}
    classifications: []

# #TODO: We should not need this.
#   getDefaultProps: ->
#     classification: API.type('classifications').create
#       name: 'Classification'
#       annotations: [] # TODO: REMOVE
#       annotation: ''
#       metadata: {}
#       'metadata.started_at': (new Date).toISOString()

  componentWillMount: ->
    @setState
      taskKey: @props.workflow.first_task

    @beginClassification()


  render: ->
    return null unless @state.currentSubjectSet?

    # annotations = @props.classification.annotations
    # currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]
    currentTask = @props.workflow.tasks[@state.taskKey] # [currentAnnotation?.task]
    TaskComponent = coreTools[currentTask.tool]
    onFirstAnnotation = @state.taskKey == @props.workflow.first_task

    if currentTask.tool is 'pick_one'
      currentAnswer = currentTask.tool_config.options?[currentAnnotation.value]
      waitingForAnswer = not currentAnswer

    <div className="classifier">
      <div className="subject-area">
        { if @state.noMoreSubjectSets
            style = marginTop: "50px"
            <p style={style}>There is nothing left to do. Thanks for your work and please check back soon!</p>
          else if @state.currentSubjectSet?
            <SubjectSetViewer
              subject_set={@state.currentSubjectSet}
              workflow={@props.workflow}
              task={currentTask}
              annotation={@getCurrentClassification().annotation ? {}}
              subToolIndex={@state.subToolIndex}
              onComplete={@handleToolComplete}
              onViewSubject={@handleViewSubject}
            />
        }
      </div>
      <div className="task-area">
        <div className="task-container">
          <TaskComponent
            task={currentTask}
            onChange={@handleDataFromTool}
            annotation={@getCurrentClassification().annotation ? {}}
            subToolIndex={@state.subToolIndex}
          />
          <hr/>
          <nav className="task-nav">
            <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
            { if @nextTask()?
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@loadNextTask}>Next</button>
              else
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@completeSubjectSet}>Done</button>
            }
          </nav>
        </div>

        <div className="forum-holder">
          <ForumSubjectWidget subject_set = @state.currentSubjectSet />
        </div>

      </div>
    </div>

  # User changed currently-viewed subject:
  handleViewSubject: (subject) ->
    @setState
      currentSubject: subject

  # User somehow indicated current task is complete; commit current classification
  handleToolComplete: (d) ->
    @handleDataFromTool(d)
    @commitClassification()
    console.log "finding error location: @handleToolComplete"
    @beginClassification()

  # Handle user selecting a pick/drawing tool:
  handleDataFromTool: (d) ->
    classifications = @state.classifications
    classifications[@state.classificationIndex].annotation[k] = v for k, v of d

    @forceUpdate()
    @setState
      classifications: classifications
        # , =>
        #   console.log 'CLASSIFICATIONS: ', classifications
        #   console.log 'CURRENT TOOL: ', @getCurrentClassification().annotation.toolName

  destroyCurrentAnnotation: ->
    # TODO: implement mechanism for going backwards to previous classification, potentially deleting later classifications from stack:
    console.log "WARN: destroyCurrentAnnotation not implemented"
    # @props.classification.annotations.pop()

  # Load next logical task
  loadNextTask: () ->
    nextTaskKey = @nextTask()?.key
    if nextTaskKey is null
      console.log 'NOTHING LEFT TO DO'
      return
    console.log 'LOADING NEXT TASK: ', nextTaskKey

    # Commit whatever current classification is:
    @commitClassification()
    # start a new one:
    @beginClassification()

    # record where we are in workflow:
    @setState
      taskKey: nextTaskKey

  # Get next logical task
  nextTask: ->
    task = @props.workflow.tasks[@state.taskKey]
    # console.log "looking up next task based on current ann: ", task, task.tool_config?.options, @getCurrentClassification().annotation?.value
    if task.tool_config?.options?[@getCurrentClassification().annotation?.value]?.next_task?
      nextKey = task.tool_config.options[@getCurrentClassification().annotation.value].next_task
    else
      nextKey = @props.workflow.tasks[@state.taskKey].next_task

    @props.workflow.tasks[nextKey]

  # Start a new classification:
  beginClassification: ->
    classifications = @state.classifications
    classifications.push new Classification()
    @setState
      classifications: classifications
      classificationIndex: classifications.length-1
        ,=>
          window.classifications = @state.classifications # make accessible to console

  # Push current classification to server:
  commitClassification: ->
    classification = @getCurrentClassification()

    classification.subject_id = @state.currentSubject.id
    classification.subject_set_id = @state.currentSubjectSet.id
    classification.workflow_id = @state.workflow.id
    classification.task_key = @state.taskKey

    classification.commit()

    console.log 'COMMITTED CLASSIFICATION: ', classification

  # Get current classification:
  getCurrentClassification: ->
    @state.classifications[@state.classificationIndex]

  completeSubjectSet: ->
    console.log "TODO: At this point, ask user if there's more to mark and then load next subjectset to classify."

    # AMS: branch classification-refactor has this commented out...
    # return
    # @props.classification.update
    #   completed: true
    #   subject_set: @state.currentSubjectSet
    #   workflow_id: @state.workflow.id
    #   console.log "Gen NEw SUB", @state.workflow.generates_new_subjects
    #   'metadata.finished_at': (new Date).toISOString()
    # @props.classification.save()
    # @props.onComplete?() # does this do anything? -STI
    # console.log 'CLASSIFICATION: ', @props.classification


window.React = React

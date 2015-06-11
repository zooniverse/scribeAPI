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

  componentWillMount: ->
    @setState
      taskKey: @props.workflow.first_task
      # TODO: insert the final task into workflow.tasks
    @beginClassification()


  render: ->
    return null unless @state.currentSubjectSet?
    console.log "mark/index state", @state
    console.log "@state.currentTask", @state.currentTask

    # TODO: can we delete the commented out code below?
    # annotations = @props.classification.annotations
    # currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]
    # currentTask = @props.workflow.tasks[@state.taskKey] unless @state.currentTask.key == "completion_assessment_task"# [currentAnnotation?.task]
    
    if @state.taskKey != "completion_assessment_task"
      currentTask = @props.workflow.tasks[@state.taskKey]
    else
      currentTask = @state.currentTask
    
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
    if @state.taskKey != "completion_assessment_task"
      task = @props.workflow.tasks[@state.taskKey] 
    else 
      task = @state.currentTask
    # console.log "looking up next task based on current ann: ", task, task.tool_config?.options, @getCurrentClassification().annotation?.value
    if task.tool_config?.options?[@getCurrentClassification().annotation?.value]?.next_task?
      nextKey = task.tool_config.options[@getCurrentClassification().annotation.value].next_task
    else
      nextKey = task.next_task

    @props.workflow.tasks[nextKey]

  # Start a new classification:
  beginClassification: ->
    console.log "beginClassification"
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
    console.log "getCurrentClassification"
    console.log "#gCC: @state", @state
    console.log "#gCC: @state.classificationIndex", @state.classificationIndex
    @state.classifications[@state.classificationIndex]

  completeSubjectSet: ->
    console.log "currentTask from #completeSubjectSet", @state.currentTask
    if @state.currentTask.key == "completion_assessment_task"
      console.log "TODO: commit yes/no classification and then load next subjectset to classify."
      @commitClassification()
    else
      completion_assessment_task = {
        "generates_subject_type": null,
        "instruction": "Is there anything left to mark?",
        "key": "completion_assessment_task",
        "next_task": null,
        "tool": "pickOne",
        "tool_config": {
            "options": {
                "affirmation": {
                    "label": "yes",
                    "next_task": null
                },
                "negation": {
                    "label": "no",
                    "next_task": null
                }
            }
        },
        "subToolIndex": 0
      }

      @setState 
        currentTask: completion_assessment_task
        taskKey: "completion_assessment_task"

window.React = React

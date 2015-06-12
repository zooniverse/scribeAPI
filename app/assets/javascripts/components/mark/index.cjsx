React                   = require 'react'
SubjectSetViewer        = require '../subject-set-viewer'
coreTools               = require 'components/core-tools'
FetchSubjectSetsMixin   = require 'lib/fetch-subject-sets-mixin'
BaseWorkflowMethods     = require 'lib/workflow-methods-mixin'
JSONAPIClient           = require 'json-api-client' # use to manage data?
ForumSubjectWidget      = require '../forum-subject-widget'


API                     = require '../../lib/api'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'

  propTypes:
    workflow: React.PropTypes.object.isRequired

  mixins: [FetchSubjectSetsMixin, BaseWorkflowMethods] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    currentSubjectSet:            null
    currentSubject:               null
    workflow:                     @props.workflow
    # project:        @props.project
    # currentTask:    @props.workflow.tasks[@props.workflow.first_task]
    taskKey:                      null
    # annotation: {}
    classifications:              []
    classificationIndex:          0

  componentWillMount: ->
    @setState
      taskKey: @props.workflow.first_task

    @beginClassification()


  render: ->
    return null unless @state.currentSubjectSet?

    console.log '<<<<<<<<<<<<<<< SUBTOOL INDEX >>>>>>>>>>>>>>>>', @state.subToolIndex
    # annotations = @props.classification.annotations
    # currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]
    currentTask = @props.workflow.tasks[@state.taskKey] # [currentAnnotation?.task]
    TaskComponent = @getCurrentTool() # coreTools[currentTask.tool]
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
              subToolIndex={@getCurrentClassification().annotation?.subToolIndex}
              onComplete={@handleToolComplete}
              onChange={@handleDataFromTool}
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
            subToolIndex={@getCurrentClassification().annotation?.subToolIndex}
          />
          <hr/>
          <nav className="task-nav">
            <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
            { if @getNextTask()?
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@advanceToNextTask}>Next</button>
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
    console.log 'handleToolComplete(): DATA = ', d
    console.log 'TASK IS COMPLETE!'
    @handleDataFromTool(d)
    @commitClassification()
    @beginClassification()

  # Handle user selecting a pick/drawing tool:
  handleDataFromTool: (d) ->
    # console.log 'handleDataFromTool(): DATA RECEIVED = ', d
    classifications = @state.classifications
    classifications[@state.classificationIndex].annotation[k] = v for k, v of d

    # console.log '[[[[[[[ CURRENT CLASSIFICATION ]]]]]]]', classifications[@state.classificationIndex]

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

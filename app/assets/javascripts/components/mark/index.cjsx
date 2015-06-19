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
    # currentSubjectSet:            null
    # currentSubject:               null
    workflow:                     @props.workflow

    taskKey:                      null
    # annotation: {}
    classifications:              []
    classificationIndex:          0
    subject_set_index:            0
    subject_index:                0

  componentWillMount: ->
    completion_assessment_task = {
        "generates_subject_type": null,
        "instruction": "Is there anything left to mark?",
        "key": "completion_assessment_task",
        "next_task": null,
        "tool": "pickOne",
        "tool_config": {
            "options": {
                "complete_subject": {
                    "label": "No",
                    "next_task": null
                },
                "incomplete_subject": {
                    "label": "Yes",
                    "next_task": null
                }
            }
        },
        "subToolIndex": 0
      }

    @props.workflow.tasks["completion_assessment_task"] = completion_assessment_task
    @setState
      taskKey: @props.workflow.first_task

    @beginClassification()

  render: ->
    return null unless @getCurrentSubject()?

    currentTask = @props.workflow.tasks[@state.taskKey] # [currentAnnotation?.task]
    TaskComponent = @getCurrentTool() # coreTools[currentTask.tool]
    onFirstAnnotation = @state.taskKey == @props.workflow.first_task

    console.log 'CURRENT TASK: ', currentTask

    if currentTask.tool is 'pick_one'
      currentAnswer = currentTask.tool_config.options?[currentAnnotation.value]
      waitingForAnswer = not currentAnswer

    <div className="classifier">
      <div className="subject-area">
        { if @state.noMoreSubjectSets
            style = marginTop: "50px"
            <p style={style}>There is nothing left to do. Thanks for your work and please check back soon!</p>
          else if @getCurrentSubjectSet()?
            <SubjectSetViewer
              subject_set={@getCurrentSubjectSet()}
              subject_index={@state.subject_index}
              workflow={@props.workflow}
              task={currentTask}
              annotation={@getCurrentClassification().annotation ? {}}
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
          />
          <hr/>
          <nav className="task-nav">
            <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
            { if @getNextTask()?
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@advanceToNextTask}>Next</button>
              else
                if @state.taskKey == "completion_assessment_task"
                  <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@completeSubjectAssessment}>Next Page</button>
                else
                  <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@completeSubjectSet}>Done</button>
            }
          </nav>
        </div>

        <div className="forum-holder">
          <ForumSubjectWidget subject_set = @getCurrentSubjectSet() />
        </div>

      </div>
    </div>

  getNextSubject: ->
    new_subject_set_index = @state.subject_set_index
    new_subject_index = @state.subject_index + 1

    # If we've exhausted pages in this subject set, move to next one:
    if new_subject_index >= @getCurrentSubjectSet().subjects.length
      new_subject_set_index += 1
      new_subject_index = 0

    # If we've exhausted all subject sets, collapse in shame
    if new_subject_set_index >= @state.subjectSets.length
      console.warn "NO MORE SUBJECT SETS"
      return

    console.log "Mark#index Advancing to subject_set_index #{new_subject_set_index} (of #{@state.subjectSets.length}), subject_index #{new_subject_index} (of #{@state.subjectSets[new_subject_set_index].subjects.length})"

    @setState
      subject_set_index: new_subject_set_index
      subject_index: new_subject_index
      taskKey: @props.workflow.first_task, =>
        # console.log "After @state", @state

  # User changed currently-viewed subject:
  handleViewSubject: (index) ->
    # console.log "HANDLE View Subject: subject", subject
    # @state.currentSubject = subject
    # @forceUpdate()
    @setState
      subject_index: index


  # User somehow indicated current task is complete; commit current classification
  handleToolComplete: (d) ->
    console.log 'handleToolComplete(): DATA = ', d
    # console.log 'TASK IS COMPLETE!'
    @handleDataFromTool(d)
    @commitClassification()
    @beginClassification()

  # Handle user selecting a pick/drawing tool:
  handleDataFromTool: (d) ->
    console.log "MARK/INDEX::handleDataFromTool()", d
    classifications = @state.classifications
    classifications[@state.classificationIndex].annotation[k] = v for k, v of d

    @setState
      classifications: classifications
        , =>
          @forceUpdate()
          console.log "handleDataFromTool(), DATA = ", d


  destroyCurrentAnnotation: ->
    # TODO: implement mechanism for going backwards to previous classification, potentially deleting later classifications from stack:
    console.log "WARN: destroyCurrentAnnotation not implemented"
    # @props.classification.annotations.pop()

  completeSubjectSet: ->
    @commitClassification()
    @beginClassification()

    # TODO: Should maybe make this workflow-configurable?
    show_subject_assessment = true
    if show_subject_assessment
      @setState
        taskKey: "completion_assessment_task"

  completeSubjectAssessment: ->
    console.log "before commit of completeSubjectSet @state", @state
    @commitClassification()
    @beginClassification()

    @getNextSubject()

window.React = React

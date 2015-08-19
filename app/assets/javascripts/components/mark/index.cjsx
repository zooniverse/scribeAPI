React                   = require 'react'
SubjectSetViewer        = require '../subject-set-viewer'
coreTools               = require 'components/core-tools'
FetchSubjectSetsMixin   = require 'lib/fetch-subject-sets-mixin'
BaseWorkflowMethods     = require 'lib/workflow-methods-mixin'
JSONAPIClient           = require 'json-api-client' # use to manage data?
ForumSubjectWidget      = require '../forum-subject-widget'
API                     = require '../../lib/api'
HelpModal               = require 'components/help-modal'
HelpButton              = require 'components/buttons/help-button'
BadSubjectButton        = require 'components/buttons/bad-subject-button'
DraggableModal          = require 'components/draggable-modal'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'

  getDefaultProps: ->
    workflowName: 'mark'
    hideOtherMarks: true

  mixins: [FetchSubjectSetsMixin, BaseWorkflowMethods] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    taskKey:                      null
    classifications:              []
    classificationIndex:          0
    subject_set_index:            0
    subject_index:                0
    currentSubToolIndex:          0
    helping:                      false

  componentDidMount: ->
    @getCompletionAssessmentTask()

  componentWillMount: ->
    @setState
      taskKey: @getActiveWorkflow().first_task

    @beginClassification()

  toggleHelp: ->
    @setState helping: not @state.helping

  render: ->
    return null unless @getCurrentSubject()? && @getActiveWorkflow()?
    currentTask = @getCurrentTask()
    TaskComponent = @getCurrentTool()
    onFirstAnnotation = @state.taskKey == @getActiveWorkflow().first_task


    if currentTask.tool is 'pick_one'
      currentAnswer = currentTask.tool_config.options?[currentAnnotation.value]
      waitingForAnswer = not currentAnswer

    <div className="classifier">

      <div className="subject-area">
        { if @state.noMoreSubjectSets
            style = marginTop: "50px"
            <p style={style}>There is nothing left to do. Thanks for your work and please check back soon!</p>

          else if @state.notice
            <DraggableModal header={@state.notice.header} onDone={@state.notice.onClick}>{@state.notice.message}</DraggableModal>

          else if @getCurrentSubjectSet()?
            <SubjectSetViewer
              subject_set={@getCurrentSubjectSet()}
              subject_index={@state.subject_index}
              workflow={@getActiveWorkflow()}
              task={currentTask}
              annotation={@getCurrentClassification().annotation ? {}}
              onComplete={@handleToolComplete}
              onChange={@handleDataFromTool}
              onViewSubject={@handleViewSubject}
              subToolIndex={@state.currentSubToolIndex}
              subjectCurrentPage={@state.subject_current_page}
              nextPage={@nextPage}
              prevPage={@prevPage}
              totalSubjectPages={@state.total_subject_pages}
              destroyCurrentClassification={@destroyCurrentClassification}
              hideOtherMarks={@props.hideOtherMarks}
            />
        }
      </div>
      <div className="task-area">
        <div className="task-container">
          <TaskComponent
            key={@getCurrentTask().key}
            task={currentTask}
            annotation={@getCurrentClassification().annotation ? {}}
            onChange={@handleDataFromTool}
            subject={@getCurrentSubject()}
          />
          <div className="help-bad-subject-holder">
            { if @getCurrentTask().help?
              <HelpButton onClick={@toggleHelp} />
            }
            { if onFirstAnnotation
              <BadSubjectButton active={@state.badSubject} onClick={@toggleBadSubject} />
            }
            { if @state.badSubject
              <p>You&#39;ve marked this subject as BAD. Thanks for flagging the issue! <strong>Press DONE to continue.</strong></p>
            }
          </div>
          <nav className="task-nav">
            { if false
              <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
            }
            { if @getNextTask()?
                console.log "STATE at the NEXT BUTTON", @state
                <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@advanceToNextTask}>Next</button>
              else
                if @state.taskKey == "completion_assessment_task"
                  if @getCurrentSubject() == @getCurrentSubjectSet().subjects[@getCurrentSubjectSet().subjects.length-1]
                    <button type="button" className="continue major-button" disabled={waitingForAnswer} onClick={@completeSubjectAssessment}>Next</button>
                  else
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

      { if @state.helping
        <HelpModal help={@getCurrentTask().help} onDone={=> @setState helping: false } />
      }
    </div>

  # User changed currently-viewed subject:
  handleViewSubject: (index) ->
    # console.log "HANDLE View Subject: subject", subject
    # @state.currentSubject = subject
    # @forceUpdate()
    @setState subject_index: index, => @forceUpdate()
    @toggleBadSubject() if @state.badSubject

  # User somehow indicated current task is complete; commit current classification
  handleToolComplete: (d) ->
    @handleDataFromTool(d)
    @commitClassification()

    # Initialize new classification with currently selected subToolIndex (so that right tool is selected in the right-col)
    # @beginClassification() #AMS (8/17): this is causing issues with autosave, moving it back to commitClassification


  # Handle user selecting a pick/drawing tool:
  handleDataFromTool: (d) ->

    # Kind of a hack: We receive annotation data from two places:
    #  1. tool selection widget in right-col
    #  2. the actual draggable marking tools
    # We want to remember the subToolIndex so that the right-col menu highlights
    # the correct tool after committing a mark. If incoming data has subToolIndex
    # but no mark location information, we know this callback was called by the
    # right-col. So only in that case, record currentSubToolIndex, which we use
    # to initialize marks going forward
    if d.subToolIndex? && ! d.x? && ! d.y?
      @setState currentSubToolIndex: d.subToolIndex

    else
      # console.log "MARK/INDEX::handleDataFromTool()", d if JSON.stringify(d) != JSON.stringify(@getCurrentClassification()?.annotation)
      classifications = @state.classifications
      classifications[@state.classificationIndex].annotation[k] = v for k, v of d

      # PB: Saving STI's notes here in case we decide tools should fully
      #   replace annotation hash rather than selectively update by key as above:
      # not clear whether we should replace annotations, or append to it --STI
      # classifications[@state.classificationIndex].annotation = d #[k] = v for k, v of d

      @setState
        classifications: classifications
          , =>
            @forceUpdate()

  destroyCurrentClassification: ->
    classifications = @state.classifications
    classifications.splice(@state.classificationIndex,1)
    @setState
      classifications: classifications
      classificationIndex: classifications.length-1

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
    @commitClassification()
    @beginClassification()
    @advanceToNextSubject()

  nextPage: (callback_fn)->
    console.log 'nextPage()'
    new_page = @state.subject_current_page + 1
    subject_set = @getCurrentSubjectSet()
    console.log "Np() subject_set", subject_set, new_page
    @fetchNextSubjectPage(subject_set.id, @getActiveWorkflow().id, new_page, 0, callback_fn)

  prevPage: (callback_fn) ->
    new_page = @state.subject_current_page - 1
    subject_set = @getCurrentSubjectSet()
    console.log "Np() subject_set", subject_set
    @fetchNextSubjectPage(subject_set.id, @getActiveWorkflow().id, new_page, 0, callback_fn)

window.React = React

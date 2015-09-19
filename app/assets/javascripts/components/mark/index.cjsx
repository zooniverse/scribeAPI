React                   = require 'react'
{Navigation}            = require 'react-router'
SubjectSetViewer        = require '../subject-set-viewer'
coreTools               = require 'components/core-tools'
FetchSubjectSetsMixin   = require 'lib/fetch-subject-sets-mixin'
BaseWorkflowMethods     = require 'lib/workflow-methods-mixin'
JSONAPIClient           = require 'json-api-client' # use to manage data?
API                     = require '../../lib/api'
HelpModal               = require 'components/help-modal'
Tutorial                = require 'components/tutorial'
HelpButton              = require 'components/buttons/help-button'
BadSubjectButton        = require 'components/buttons/bad-subject-button'
HideOtherMarksButton    = require 'components/buttons/hide-other-marks-button'
DraggableModal          = require 'components/draggable-modal'
Draggable               = require 'lib/draggable'
{Link}                  = require 'react-router'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'

  propTypes:
    setTutorialComplete: React.PropTypes.func.isRequired

  getDefaultProps: ->
    workflowName: 'mark'
    # hideOtherMarks: false

  mixins: [FetchSubjectSetsMixin, BaseWorkflowMethods, Navigation] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    taskKey:             null
    classifications:     []
    classificationIndex: 0
    subject_set_index:   0
    subject_index:       0
    currentSubToolIndex: 0
    helping:             false
    hideOtherMarks:      false
    currentSubtool:      null
    showingTutorial:     ! @props.project.current_user_tutorial # Initially show the tutorial if the user hasn't seen it
    lightboxHelp:        false
    activeSubjectHelper: null

  componentDidMount: ->
    @getCompletionAssessmentTask()
    @fetchSubjectSetsBasedOnProps()

  componentWillMount: ->
    @setState taskKey: @getActiveWorkflow().first_task
    @beginClassification()

  componentDidUpdate: (prev_props) ->
    # If visitor nav'd from, for example, /mark/[some id] to /mark, this component won't re-mount, so detect transition here:
    if prev_props.hash != @props.hash
      @fetchSubjectSetsBasedOnProps()

  toggleHelp: ->
    @setState helping: not @state.helping
    @hideSubjectHelp()

  toggleTutorial: ->
    @setState showingTutorial: not @state.showingTutorial
    @hideSubjectHelp()

  toggleLightboxHelp: ->
    @setState lightboxHelp: not @state.lightboxHelp
    @hideSubjectHelp()

  toggleHideOtherMarks: ->
    @setState hideOtherMarks: not @state.hideOtherMarks

  # User changed currently-viewed subject:
  handleViewSubject: (index) ->
    @setState subject_index: index, => @forceUpdate()
    @toggleBadSubject() if @state.badSubject

  # User somehow indicated current task is complete; commit current classification
  handleToolComplete: (annotation) ->
    @handleDataFromTool(annotation)
    @createAndCommitClassification(annotation)

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
      @setState currentSubtool: d.tool if d.tool?

    else
      # console.log "MARK/INDEX::handleDataFromTool()", d if JSON.stringify(d) != JSON.stringify(@getCurrentClassification()?.annotation)
      classifications = @state.classifications
      classifications[@state.classificationIndex].annotation[k] = v for k, v of d

      # console.log 'classification.annotation = ', classifications[@state.classificationIndex].annotation


      # PB: Saving STI's notes here in case we decide tools should fully
      #   replace annotation hash rather than selectively update by key as above:
      # not clear whether we should replace annotations, or append to it --STI
      # classifications[@state.classificationIndex].annotation = d #[k] = v for k, v of d

      @setState
        classifications: classifications
          , =>
            @forceUpdate()

  handleMarkDelete: (m) ->
    @flagSubjectAsUserDeleted m.subject_id

  destroyCurrentClassification: ->
    classifications = @state.classifications
    classifications.splice(@state.classificationIndex,1)
    @setState
      classifications: classifications
      classificationIndex: classifications.length-1

    # There should always be an empty classification ready to receive data:
    @beginClassification()

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
    new_page = @state.subjects_current_page + 1
    subject_set = @getCurrentSubjectSet()
    @fetchNextSubjectPage(subject_set.id, @getActiveWorkflow().id, new_page, 0, callback_fn)

  prevPage: (callback_fn) ->
    new_page = @state.subjects_current_page - 1
    subject_set = @getCurrentSubjectSet()
    @fetchNextSubjectPage(subject_set.id, @getActiveWorkflow().id, new_page, 0, callback_fn)

  showSubjectHelp: (subject_type) ->
    @setState
      activeSubjectHelper: subject_type
      helping: false
      showingTutorial: false
      lightboxHelp: false

  hideSubjectHelp: () ->
    @setState
      activeSubjectHelper: null

  render: ->
    return null unless @getCurrentSubject()? && @getActiveWorkflow()?

    currentTask = @getCurrentTask()
    TaskComponent = @getCurrentTool()
    activeWorkflow = @getActiveWorkflow()
    firstTask = activeWorkflow.first_task
    onFirstAnnotation = @state.taskKey == firstTask
    currentSubtool = if @state.currentSubtool then @state.currentSubtool else @getTasks()[firstTask]?.tool_config.tools?[0]

    # direct link to this page
    pageURL = "#{location.origin}/#/mark?subject_set_id=#{@getCurrentSubjectSet().id}&selected_subject_id=#{@getCurrentSubject().id}"


    if currentTask?.tool is 'pick_one'
      currentAnswer = (a for a in currentTask.tool_config.options when a.value == currentAnnotation.value)[0]
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
              annotation={@getCurrentClassification()?.annotation ? {}}
              onComplete={@handleToolComplete}
              onChange={@handleDataFromTool}
              onDestroy={@handleMarkDelete}
              onViewSubject={@handleViewSubject}
              subToolIndex={@state.currentSubToolIndex}
              nextPage={@nextPage}
              prevPage={@prevPage}
              subjectCurrentPage={@state.subjects_current_page}
              totalSubjectPages={@state.subjects_total_pages}
              destroyCurrentClassification={@destroyCurrentClassification}
              hideOtherMarks={@state.hideOtherMarks}
              toggleHideOtherMarks={@toggleHideOtherMarks}
              currentSubtool={currentSubtool}
              lightboxHelp={@toggleLightboxHelp}
              pageURL={pageURL}
              project={@props.project}
              toggleTutorial={@toggleTutorial}
              completeTutorial={@state.completeTutorial}
              showingTutorial={@state.showingTutorial}
            />
        }
      </div>
      <div className="right-column">
        <div className="task-area">
          <div className="task-container">
            { if @getCurrentTask().help?
              <svg id="task-help" width="100%" height="14px" viewBox="0 0 14 14" onClick={@toggleHelp}>
                <path fillRule="evenodd" d="M 7 0C 3.13 0 0 3.13 0 7 0 10.87 3.13 14 7 14 10.87 14 14 10.87 14 7 14 3.13 10.87 0 7 0ZM 7.04 11.13C 6.51 11.13 6.07 10.68 6.07 10.15 6.07 9.63 6.51 9.18 7.04 9.18 7.57 9.18 8.01 9.63 8.01 10.15 8.01 10.68 7.57 11.13 7.04 11.13ZM 7.56 7.66C 7.56 7.85 7.65 8.06 7.77 8.16 7.77 8.16 6.47 8.55 6.47 8.55 6.21 8.27 6.07 7.91 6.07 7.49 6.07 6.06 7.82 5.9 7.82 5.07 7.82 4.7 7.54 4.39 6.89 4.39 6.29 4.39 5.78 4.69 5.41 5.13 5.41 5.13 4.44 4.04 4.44 4.04 5.07 3.29 6.03 2.87 7.07 2.87 8.61 2.87 9.56 3.65 9.56 4.77 9.56 6.52 7.56 6.65 7.56 7.66Z" fill="rgb(0,0,0)" opacity="0.20"/>
              </svg>
            }
            <TaskComponent
              key={@getCurrentTask().key}
              task={currentTask}
              annotation={@getCurrentClassification()?.annotation ? {}}
              onChange={@handleDataFromTool}
              subject={@getCurrentSubject()}
            />
            <div className="help-bad-subject-holder">
              { if onFirstAnnotation
                <BadSubjectButton label={"Bad " + @props.project.term('subject')} active={@state.badSubject} onClick={@toggleBadSubject} />
              }
              { if @state.badSubject
                <p>You&#39;ve marked this {@props.project.term('subject')} as BAD. Thanks for flagging the issue! <strong>Press DONE to continue.</strong></p>
              }
            </div>

            <nav className="task-nav">
              { if false
                <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
              }
              { if @getNextTask()?
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

            {
              if @getActiveWorkflow()? && @getWorkflowByName('transcribe')?
                <p>
                  <Link to="/transcribe/#{@getWorkflowByName('transcribe').id}/#{@getCurrentSubject().id}" className={"minor-button ghost"}>Transcribe this {@props.project.term('subject')} now!</Link>
                </p>
            }
          </div>

        </div>
      </div>
      { if @props.project.tutorial? && @state.showingTutorial
        <Tutorial tutorial={@props.project.tutorial} toggleTutorial={@toggleTutorial} setTutorialComplete={@props.setTutorialComplete} />
      }
      { if @state.helping
        <HelpModal help={@getCurrentTask().help} onDone={=> @setState helping: false } />
      }
      {
        if @state.lightboxHelp
          <HelpModal help={{title: "The Lightbox", body: "Use the Lightbox to navigate through a set of documents. You can select any of the images in the Lighbox by clicking on the thumbnail. Once selected, you can start submitting classifications. You do not need to go through the images in order. However, once you start classifying an image, the Lightbox will be deactivated until that classification is done."}} onDone={=> @setState lightboxHelp: false } />
      }
      {
        if @getCurrentTask()?
          for tool, i in @getCurrentTask().tool_config.options
            if tool.help && tool.generates_subject_type && @state.activeSubjectHelper == tool.generates_subject_type
              <HelpModal help={tool.help} onDone={@hideSubjectHelp} />
      }

    </div>


window.React = React

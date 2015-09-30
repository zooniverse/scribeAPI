React                   = require 'react'
{Navigation}            = require 'react-router'
SubjectSetViewer        = require '../subject-set-viewer'
coreTools               = require 'components/core-tools'
FetchSubjectSetsMixin   = require 'lib/fetch-subject-sets-mixin'
BaseWorkflowMethods     = require 'lib/workflow-methods-mixin'
JSONAPIClient           = require 'json-api-client' # use to manage data?
ForumSubjectWidget      = require '../forum-subject-widget'
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
    # console.log "WARN: destroyCurrentAnnotation not implemented"
    # @props.classification.annotations.pop()

  completeSubjectSet: ->
    @commitCurrentClassification()
    @beginClassification()

    # TODO: Should maybe make this workflow-configurable?
    show_subject_assessment = true
    if show_subject_assessment
      @setState
        taskKey: "completion_assessment_task"

  completeSubjectAssessment: ->
    @commitCurrentClassification()
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
            />
        }
      </div>
      <div className="right-column">
        <div className={"task-area " + @getActiveWorkflow().name}>
          { if @getCurrentTask()?
              <div className="task-container">
                <TaskComponent
                  key={@getCurrentTask().key}
                  task={currentTask}
                  annotation={@getCurrentClassification()?.annotation ? {}}
                  onChange={@handleDataFromTool}
                  onSubjectHelp={@showSubjectHelp}
                  subject={@getCurrentSubject()}
                />

                <nav className="task-nav">
                  { if false
                    <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
                  }
                  { if @getNextTask() and not @state.badSubject?
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

                <div className="help-bad-subject-holder">
                  { if @getCurrentTask().help?
                    <HelpButton onClick={@toggleHelp} label="" className="task-help-button" />
                  }
                  { if onFirstAnnotation
                    <BadSubjectButton class="bad-subject-button" label={"Bad " + @props.project.term('subject')} active={@state.badSubject} onClick={@toggleBadSubject} />
                  }
                  { if @state.badSubject
                    <p>You&#39;ve marked this {@props.project.term('subject')} as BAD. Thanks for flagging the issue! <strong>Press DONE to continue.</strong></p>
                  }
                </div>
              </div>
          }

          <div className="task-secondary-area">

            {
              if @getCurrentTask()?
                <p>
                  <a className="tutorial-link" onClick={@toggleTutorial}>View A Tutorial</a>
                </p>
            }

            {
              if @getCurrentTask()? && @getActiveWorkflow()? && @getWorkflowByName('transcribe')?
                <p>
                  <Link to="/transcribe/#{@getWorkflowByName('transcribe').id}/#{@getCurrentSubject().id}" className="transcribe-link">Transcribe this {@props.project.term('subject')} now!</Link>
                </p>
            }

            <div className="forum-holder">
              <ForumSubjectWidget subject={@getCurrentSubject()} subject_set={@getCurrentSubjectSet()} project={@props.project} />
            </div>

            <div className="social-media-container">
              <a href="https://www.facebook.com/sharer.php?u=#{encodeURIComponent pageURL}" target="_blank">
                <i className="fa fa-facebook-square"/>
              </a>
              <a href="https://twitter.com/home?status=#{encodeURIComponent pageURL}%0A" target="_blank">
                <i className="fa fa-twitter-square"/>
              </a>
              <a href="https://plus.google.com/share?url=#{encodeURIComponent pageURL}" target="_blank">
                <i className="fa fa-google-plus-square"/>
              </a>
            </div>
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
          <HelpModal help={{title: "The Lightbox", body: "<p>This Lightbox displays a complete set of documents in order. You can use it to go through the documents sequentially—but feel free to do them in any order that you like! Just click any thumbnail to open that document and begin marking it.</p><p>However, please note that **once you start marking a page, the Lightbox becomes locked ** until you finish marking that page! You can select a new page once you have finished.</p>"}} onDone={=> @setState lightboxHelp: false } />
      }
      {
        if @getCurrentTask()?
          for tool, i in @getCurrentTask().tool_config.options
            if tool.help && tool.generates_subject_type && @state.activeSubjectHelper == tool.generates_subject_type
              <HelpModal help={tool.help} onDone={@hideSubjectHelp} />
      }

    </div>


window.React = React

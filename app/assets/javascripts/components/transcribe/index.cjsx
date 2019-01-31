
# @cjsx React.DOM
React                   = require 'react'
{Navigation}            = require 'react-router'
SubjectViewer           = require '../subject-viewer'
JSONAPIClient           = require 'json-api-client' # use to manage data?
FetchSubjectsMixin      = require 'lib/fetch-subjects-mixin'
ForumSubjectWidget      = require '../forum-subject-widget'

BaseWorkflowMethods     = require 'lib/workflow-methods-mixin'

# Hash of core tools:
coreTools               = require 'components/core-tools'

# Hash of transcribe tools:
transcribeTools         = require './tools'

RowFocusTool            = require '../row-focus-tool'
API                     = require '../../lib/api'

HelpModal               = require 'components/help-modal'
Tutorial                = require 'components/tutorial'
DraggableModal          = require 'components/draggable-modal'
GenericButton           = require 'components/buttons/generic-button'
NoMoreSubjectsModal     = require 'components/no-more-subjects-modal'

module.exports = React.createClass # rename to Classifier
  displayName: 'Transcribe'
  mixins: [FetchSubjectsMixin, BaseWorkflowMethods, Navigation] # load subjects and set state variables: subjects,  classification

  getInitialState: ->
    taskKey:                      null
    classifications:              []
    classificationIndex:          0
    subject_index:                0
    helping:                      false
    last_mark_task_key:           @props.query.mark_key
    showingTutorial:              false

  getDefaultProps: ->
    workflowName: 'transcribe'

  componentWillMount: ->
    @beginClassification()

  fetchSubjectsCallback: ->
    @setState taskKey: @getCurrentSubject().type if @getCurrentSubject()?

  __DEP__handleTaskComponentChange: (val) ->
    taskOption = @getCurrentTask().tool_config.options[val]
    if taskOption.next_task?
      @advanceToTask taskOption.next_task

  # Handle user selecting a pick/drawing tool:
  handleDataFromTool: (d) ->
    classifications = @state.classifications
    currentClassification = classifications[@state.classificationIndex]

    # this is a source of conflict. do we copy key/value pairs, or replace the entire annotation? --STI
    currentClassification.annotation[k] = v for k, v of d

    @setState
      classifications: classifications,
        => @forceUpdate()

  handleTaskComplete: (d) ->
    @handleDataFromTool(d)
    @commitClassificationAndContinue d

  handleViewerLoad: (props) ->
    @setState
      viewerSize: props.size

    if (tool = @refs.taskComponent)?
      tool.onViewerResize props.size

  makeBackHandler: ->
    () =>
      console.log "go back"

  toggleHelp: ->
    @setState helping: not @state.helping

  toggleTutorial: ->
    @setState showingTutorial: not @state.showingTutorial

  hideTutorial: ->
    @setState showingTutorial: false

  componentWillUnmount:->
    # PB: What's intended here? Docs state `void componentWillUnmount()`, so not sure what this serves:
    not @state.badSubject

  # transition back to mark workflow
  returnToMarking: ->
    @transitionTo 'mark', {},
      subject_set_id: @getCurrentSubject().subject_set_id
      selected_subject_id: @getCurrentSubject().parent_subject_id
      mark_task_key: @props.query.mark_key
      subject_id: @getCurrentSubject().id

      page: @props.query.page

  render: ->
    if @props.query.from == 'verify'
      transcribeMode = 'verify'
    else if @props.params.workflow_id? and @props.params.parent_subject_id?
      transcribeMode = 'page'
    else if @props.params.subject_id
      transcribeMode = 'single'
    else
      transcribeMode = 'random'

    if @state.subjects?
      isLastSubject = ( @state.subject_index >= @state.subjects.length - 1 )
    else isLastSubject = null

    currentAnnotation = @getCurrentClassification().annotation
    currentAnnotation = @props.query.annotation if @props.query.annotation?
    TranscribeComponent = @getCurrentTool() # @state.currentTool
    onFirstAnnotation = currentAnnotation?.task is @getActiveWorkflow().first_task

    <div className="classifier">
      <div className="subject-area">
        {
          unless @getCurrentSubject() || @state.noMoreSubjects
            <DraggableModal
              header          = { "Loading transcription subjects." }
              buttons         = {<GenericButton label='Back to Marking' href='/#/mark' />}
            >
                We are currently looking for a subject for you to {@props.workflowName}.
            </DraggableModal>
        }

        { if @state.noMoreSubjects
            <NoMoreSubjectsModal header={ if @state.userClassifiedAll then "Thanks for transcribing!" else "Nothing to transcribe" } workflowName={@props.workflowName} project={@props.project} />
            
          else if @getCurrentSubject()? and @getCurrentTask()?

            <SubjectViewer
              onLoad={@handleViewerLoad}
              task={@getCurrentTask()}
              subject={@getCurrentSubject()}
              active=true
              workflow={@getActiveWorkflow()}
              classification={@props.classification}
              annotation={currentAnnotation}
            >
              <TranscribeComponent
                viewerSize={@state.viewerSize}
                annotation_key={"#{@state.taskKey}.#{@getCurrentSubject().id}"}
                key={@getCurrentTask().key}
                task={@getCurrentTask()}
                annotation={currentAnnotation}
                subject={@getCurrentSubject()}
                onChange={@handleDataFromTool}
                subjectCurrentPage={@props.query.page}
                onComplete={@handleTaskComplete}
                onBack={@makeBackHandler()}
                workflow={@getActiveWorkflow()}
                viewerSize={@state.viewerSize}
                transcribeTools={transcribeTools}
                onShowHelp={@toggleHelp if @getCurrentTask().help?}
                badSubject={@state.badSubject}
                onBadSubject={@toggleBadSubject}
                illegibleSubject={@state.illegibleSubject}
                onIllegibleSubject={@toggleIllegibleSubject}
                returnToMarking={@returnToMarking}
                transcribeMode={transcribeMode}
                isLastSubject={isLastSubject}
                project={@props.project}
              />

            </SubjectViewer>
        }
      </div>

      { if @getCurrentTask()? and @getCurrentSubject()
          nextTask =
            if @getCurrentTask().tool_config.options?[currentAnnotation.value]?
              @getCurrentTask().tool_config.options?[currentAnnotation.value].next_task
            else
              @getCurrentTask().next_task

          <div className="right-column">
            <div className="task-area transcribe">

              <div className="task-secondary-area">

                {
                  if @getCurrentTask()?
                    <p>
                      <a className="tutorial-link" onClick={@toggleTutorial}>View A Tutorial</a>
                    </p>
                }

                <div className="forum-holder">
                  <ForumSubjectWidget subject=@getCurrentSubject() project={@props.project} />
                </div>

              </div>

            </div>
          </div>
      }

      { if @props.project.tutorial? && @state.showingTutorial
          # Check for workflow-specific tutorial
          if @props.project.tutorial.workflows? && @props.project.tutorial.workflows[@getActiveWorkflow()?.name]
            <Tutorial tutorial={@props.project.tutorial.workflows[@getActiveWorkflow().name]} onCloseTutorial={@hideTutorial} />
          # Otherwise just show general tutorial
          else
            <Tutorial tutorial={@props.project.tutorial} onCloseTutorial={@hideTutorial} />
      }

      { if @state.helping
        <HelpModal help={@getCurrentTask().help} onDone={=> @setState helping: false } />
      }

    </div>

window.React = React

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
DraggableModal          = require 'components/draggable-modal'
GenericButton           = require 'components/buttons/generic-button'

module.exports = React.createClass # rename to Classifier
  displayName: 'Transcribe'
  mixins: [FetchSubjectsMixin, BaseWorkflowMethods, Navigation] # load subjects and set state variables: subjects,  classification

  getInitialState: ->
    taskKey:                      null
    classifications:              []
    classificationIndex:          0
    subject_index:                0
    helping:                      false

  getDefaultProps: ->
    workflowName: 'transcribe'

  componentWillMount: ->
    @beginClassification()

  fetchSubjectsCallback: ->
    @setState taskKey: @getCurrentSubject().type if @getCurrentSubject()?

  handleTaskComponentChange: (val) ->
    # console.log "handleTaskComponentChange val", val
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

  componentWillUnmount:->
    not @state.badSubject

  # this can go into a mixin? (common across all transcribe tools)
  returnToMarking: ->
    console.log 'TRANSCRIBE-INDEX::returnToMarking()'

    # transition back to mark
    @transitionTo 'mark', {},
      subject_set_id: @getCurrentSubject().subject_set_id
      selected_subject_id: @getCurrentSubject().parent_subject_id
      page: @props.query.page

  render: ->
    if @props.params.workflow_id? and @props.params.parent_subject_id?
      transcribeMode = 'page'
      console.log 'TRANSCRIBING ENTIRE PAGE!'
    else if @props.params.subject_id
      console.log 'TRANSCRIBING SINGLE SUBJECT!'
      transcribeMode = 'single'
    else
      console.log 'TRANSCRIBING RANDOMLY!'
      transcribeMode = 'random'

    if @state.subjects?
      console.log 'SUBJECT INDEX = ', @state.subject_index
      console.log 'SUBJECTS LENGTH = ', @state.subjects.length
      isLastSubject = ( @state.subject_index >= @state.subjects.length - 1 )
    else isLastSubject = null

    console.log '++++++++++++++++++++++++++++++++++++'
    console.log 'isLastSubject = ', isLastSubject
    console.log '++++++++++++++++++++++++++++++++++++'

    currentAnnotation = @getCurrentClassification().annotation
    TranscribeComponent = @getCurrentTool() # @state.currentTool
    onFirstAnnotation = currentAnnotation?.task is @getActiveWorkflow().first_task

    <div className="classifier">
      <div className="subject-area">

        { unless @getCurrentSubject()
            <DraggableModal
              header          = { if @state.userClassifiedAll then "You transcribed them all!" else "Nothing to transcribe" }
              buttons         = {<GenericButton label='Continue' href='/#/mark' />}
            >
                There are currently no {@props.workflowName} subjects. Try <a href="/#/mark">marking</a> instead!
            </DraggableModal>

          else if @getCurrentSubject()? and @getCurrentTask()?

            # console.log "@getCurrentTask().key", @getCurrentTask().key
            # console.log "rendering text tool: ", "#{@state.taskKey}.#{@getCurrentSubject().id}", currentAnnotation
            <SubjectViewer
              onLoad={@handleViewerLoad}
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

          <div className="task-area">

            <div className="forum-holder">
              <ForumSubjectWidget subject=@getCurrentSubject() />
            </div>

          </div>
      }

      { if @state.helping
        <HelpModal help={@getCurrentTask().help} onDone={=> @setState helping: false } />
      }

    </div>

window.React = React

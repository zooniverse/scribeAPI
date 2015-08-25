# @cjsx React.DOM
React                   = require 'react'
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
  mixins: [FetchSubjectsMixin, BaseWorkflowMethods] # load subjects and set state variables: subjects,  classification

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

  __DEP__handleTaskComponentChange: (val) ->
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



  render: ->
    # DISABLE ANIMATED SCROLLING FOR NOW
    # if @props.query.scrollX? and @props.query.scrollY?
    #   window.scrollTo(@props.query.scrollX,@props.query.scrollY)
    # console.log "transcribe#index @props", @props 
    # console.log "transcribe#index @state", @state 
    currentAnnotation = @getCurrentClassification().annotation
    TranscribeComponent = @getCurrentTool() # @state.currentTool
    onFirstAnnotation = currentAnnotation?.task is @getActiveWorkflow().first_task

    <div className="classifier">
      <div className="subject-area">

        { if ! @getCurrentSubject()
            <DraggableModal
              header          = { if @state.userClassifiedAll then "Thanks for transcribing!" else "Nothing to transcribe" }
              buttons         = {<GenericButton label='Continue' href='/#/mark' />}
            >
                Currently, there are no subjects to {@props.workflowName}. Try <a href="/#/mark">marking</a> instead!
            </DraggableModal>

          else if @getCurrentSubject()? and @getCurrentTask()?
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
            <div className="task-area">

              <div className="forum-holder">
                <ForumSubjectWidget subject=@getCurrentSubject() />
              </div>

            </div>
          </div>
      }

      { if @state.helping
        <HelpModal help={@getCurrentTask().help} onDone={=> @setState helping: false } />
      }

    </div>

window.React = React

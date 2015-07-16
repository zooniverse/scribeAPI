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

module.exports = React.createClass # rename to Classifier
  displayName: 'Transcribe'
  mixins: [FetchSubjectsMixin, BaseWorkflowMethods] # load subjects and set state variables: subjects,  classification

  getInitialState: ->
    taskKey:                      null
    classifications:              []
    classificationIndex:          0
    subject_index:                0

  getDefaultProps: ->
    workflowName: 'transcribe'

  componentWillMount: ->
    @beginClassification()

  fetchSubjectsCallback: ->
    #TODO: We do need to account for times when there are no subjects? type won't do that. -AMS
    console.log 'CURRENT SUBJECT: ', @getCurrentSubject()

    currentSubject = @getCurrentSubject()
    console.log "feCallBack currentSubject", currentSubject
    if not currentSubject?
      @setState noMoreSubjects: true, => @forceUpdate()
    else
      console.log "currentSubject.type", @getCurrentSubject().type
      @setState taskKey: @getCurrentSubject().type

    # @advanceToTask new_key

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

    @forceUpdate()
    @setState
      classifications: classifications
        , =>
          @forceUpdate()
          # console.log "handleDataFromTool(), DATA = ", d

  handleTaskComplete: (d) ->
    console.log 'handleTaskComplete(), data = ', d
    @handleDataFromTool(d)
    @commitClassification()
    @beginClassification {}, () =>
      if @getCurrentTask().next_task?
        # console.log "advance to next task...", @state.currentTask['next_task']
        @advanceToTask @getCurrentTask().next_task

      else
        @advanceToNextSubject()

  advanceToNextSubject: ->
    # console.log 'advanceToNextSubject()'
    # console.log "subjects: ", @state.subjects
    console.log "@state.subject_index", @state.subject_index
    if @state.subject_index + 1 < @state.subjects.length
      next_index = @state.subject_index + 1
      next_subject = @state.subjects[next_index]
      # console.log 'NEXT SUBJECT: ', next_subject
      @setState
        # currentSubject: next_subject
        taskKey: next_subject.type
        subject_index: next_index
        , =>
          key = @getCurrentSubject().type
          @advanceToTask key
    else
      console.warn "WARN: End of subjects"
      @setState noMoreSubjects: true

  handleViewerLoad: (props) ->
    # console.log "Transcribe#handleViewerLoad: setting size: ", props
    @setState
      viewerSize: props.size

    if (tool = @refs.taskComponent)?
      tool.onViewerResize props.size

  makeBackHandler: ->
    () =>
      console.log "go back"

  render: ->
    # DISABLE ANIMATED SCROLLING FOR NOW
    # if @props.query.scrollX? and @props.query.scrollY?
    #   window.scrollTo(@props.query.scrollX,@props.query.scrollY)
    console.log "transcribe#index @props", @props 
    console.log "transcribe#index @state", @state 
    currentAnnotation = @getCurrentClassification().annotation
    TranscribeComponent = @getCurrentTool() # @state.currentTool
    onFirstAnnotation = currentAnnotation?.task is @activeWorkflow().first_task

    <div className="classifier">
      <div className="subject-area">

        { if @state.noMoreSubjects
            style = marginTop: "50px"
            <p style={style}>There are currently no transcription subjects. Try <a href="/#/mark">marking</a> instead!</p>
          else if @getCurrentSubject()? and @getCurrentTask()?
            <SubjectViewer
              onLoad={@handleViewerLoad}
              subject={@getCurrentSubject()}
              active=true
              workflow={@activeWorkflow()}
              classification={@props.classification}
              annotation={currentAnnotation}
            >
              <TranscribeComponent
                viewerSize={@state.viewerSize}
                annotation_key={@state.taskKey}
                task={@getCurrentTask()}
                annotation={currentAnnotation}
                subject={@getCurrentSubject()}
                onChange={@handleDataFromTool}
                onComplete={@handleTaskComplete}
                onBack={@makeBackHandler()}
                workflow={@activeWorkflow()}
                viewerSize={@state.viewerSize}
                transcribeTools={transcribeTools}
              />

            </SubjectViewer>
        }
      </div>

      { if @getCurrentTask()? and not @state.noMoreSubjects
          nextTask =
            if @getCurrentTask().tool_config.options?[currentAnnotation.value]?
              @getCurrentTask().tool_config.options?[currentAnnotation.value].next_task
            else
              @getCurrentTask().next_task

          <div className="task-area">

            <div className="task-container" style={display: "none"} >
              <nav className="task-nav">
                <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
                { if nextTask?
                    <button type="button" className="continue major-button" onClick={@advanceToNextTask.bind(@, nextTask)}>Next</button>
                  else
                    <button type="button" className="continue major-button" onClick={@completeClassification}>Done</button>
                }
              </nav>
            </div>

            <div className="forum-holder">
              <ForumSubjectWidget subject=@getCurrentSubject() />
            </div>

          </div>
      }
    </div>

window.React = React

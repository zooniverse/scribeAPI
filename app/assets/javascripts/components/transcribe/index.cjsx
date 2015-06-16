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
  mixins: [FetchSubjectsMixin, BaseWorkflowMethods] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    workflow:                     @props.workflow
    currentSubject:               null
    taskKey:                      null
    classifications:              []
    classificationIndex:          0


  componentWillMount: ->
    @beginClassification()

  fetchSubjectsCallback: ->
    console.log 'fetchSubjectsCallback(), TASK KEY  = ', @state.currentSubject.type
    #TODO: We do need to account for times when there are no subjects? type won't do that. -AMS

    @setState taskKey: @state.currentSubject.type
    # @advanceToTask new_key

  handleTaskComponentChange: (val) ->
    # console.log "handleTaskComponentChange val", val
    taskOption = @getCurrentTask().tool_config.options[val]
    if taskOption.next_task?
      @advanceToTask taskOption.next_task

  # Handle user selecting a pick/drawing tool:
  handleDataFromTool: (d) ->
    classifications = @state.classifications
    classifications[@state.classificationIndex].annotation[k] = v for k, v of d

    # @forceUpdate()
    @setState
      classifications: classifications

  handleTaskComplete: (d) ->
    console.log 'handleTaskComplete()'
    @handleDataFromTool(d)
    @commitClassification()
    @beginClassification()

    if @getCurrentTask().next_task?
      # console.log "advance to next task...", @state.currentTask['next_task']
      @advanceToTask @getCurrentTask().next_task

    else
      @advanceToNextSubject()

  advanceToNextSubject: ->
    console.log 'advanceToNextSubject()'
    currentIndex = (i for s, i in @state.subjects when s['id'] == @state.currentSubject['id'])[0]
    # console.log "subjects: ", @state.subjects
    if currentIndex + 1 < @state.subjects.length
      nextSubject = @state.subjects[currentIndex + 1]
      console.log 'NEXT SUBJECT: ', nextSubject
      console.log 'NEXT TASK KEY: ', nextSubject.type
      @setState
        taskKey: nextSubject.type
        currentSubject: nextSubject
        , =>
          key = @state.currentSubject.type
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
    return null unless @getCurrentTask()? # @state.currentTask?

    if @props.query.scrollX? and @props.query.scrollY?
      window.scrollTo(@props.query.scrollX,@props.query.scrollY)

    # annotations = @props.annotations
    currentAnnotation = @getCurrentClassification().annotation

    # console.log "Transcribe#render: "
    # console.dir currentAnnotation
    TaskComponent = @getCurrentTool() # @state.currentTool
    onFirstAnnotation = currentAnnotation?.task is @props.workflow.first_task

    # console.log "Transcribe#render: tool=#{@state.currentTask.tool} TaskComponent=", TaskComponent

    nextTask =
      if @getCurrentTask().tool_config.options?[currentAnnotation.value]?
        @getCurrentTask().tool_config.options?[currentAnnotation.value].next_task
      else
        @getCurrentTask().next_task

    # console.log 'NEXT TASK IS: ', nextTask
    # console.log 'TRANSCRIBE::render(), CURRENT SUBJCT = ', @state.currentSubject
    # console.log "viewer size: ", @state.viewerSize
    <div className="classifier">
      <div className="subject-area">
        { if @state.noMoreSubjects
            style = marginTop: "50px"
            <p style={style}>There are currently no transcription subjects. Try <a href="/#/mark">marking</a> instead!</p>
          else if @state.currentSubject?
            <SubjectViewer
              onLoad={@handleViewerLoad}
              subject={@state.currentSubject}
              active=true
              workflow={@props.workflow}
              classification={@props.classification}
              annotation={currentAnnotation}
            >
              <TaskComponent
                ref="taskComponent"
                viewerSize={@state.viewerSize}
                key={@state.taskKey}
                task={@getCurrentTask()}
                annotation={currentAnnotation}
                subject={@state.currentSubject}
                onChange={@handleTaskComponentChange}
                onComplete={@handleTaskComplete}
                onBack={@makeBackHandler()}
                workflow={@props.workflow}
                viewerSize={@state.viewerSize}
                transcribeTools={transcribeTools}
              />
            </SubjectViewer>
        }
      </div>

      { unless @state.noMoreSubjects
          <div style={display: "none"} className="task-area">

            <div className="task-container">
              <nav className="task-nav">
                <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
                { if nextTask?
                    <button type="button" className="continue major-button" onClick={@advanceToTask.bind(@, nextTask)}>Next</button>
                  else
                    <button type="button" className="continue major-button" onClick={@completeClassification}>Done</button>
                }
              </nav>
            </div>

            <div className="forum-holder">
              <ForumSubjectWidget subject_set=@state.currentSubject />
            </div>

          </div>
      }
    </div>

window.React = React

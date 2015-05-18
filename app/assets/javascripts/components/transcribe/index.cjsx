# @cjsx React.DOM
React              = require 'react'
SubjectViewer      = require '../subject-viewer'
JSONAPIClient      = require 'json-api-client' # use to manage data?
FetchSubjectsMixin = require 'lib/fetch-subjects-mixin'
ForumSubjectWidget = require '../forum-subject-widget'

# Hash of core tools:
coreTools          = require 'components/core-tools'

# Hash of transcribe tools:
transcribeTools   = require './tools'

resource = new JSONAPIClient

RowFocusTool       = require '../row-focus-tool'
API                = require '../../lib/api'

module.exports = React.createClass # rename to Classifier
  displayName: 'Transcribe'
  mixins: [FetchSubjectsMixin] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    workflow: @props.workflow

  getDefaultProps: ->
    classification: resource.type('classifications').create
      name: 'Classification'
      annotations: []
      metadata: {}
    annotations: []
    # overrideFetchSubjectsUrl: '/fake-transcription-subjects.json'

  fetchSubjectsCallback: ->
    new_key = @state.workflow.first_task
    @advanceToTask new_key

  handleTaskComponentChange: (val) ->
    taskOption = @state.currentTask.options[val]
    if taskOption.next_task?
      @advanceToTask taskOption.next_task

  advanceToTask: (key) ->

    key = @translateLogicTaskKey key
    task = @state.workflow.tasks[ key ]
    task.key = key

    tool = coreTools[task?.tool] ? transcribeTools[task?.tool]
    if ! task?
      console.log "WARN: Invalid task key: ", key

    else if ! tool?
      console.log "Props", @props
      console.log "STATE", @state
      console.log "WARN: Invalid tool specified in #{key}: #{task.tool}"

    else
      console.log "Transcribe#advanceToTask(#{key}): tool=#{task.tool}"

      @setState
        currentTaskKey: key
        currentTask: task
        currentTool: tool

  translateLogicTaskKey: (key) ->
    # console.log "Transcribe#translateLogicTaskKey: #{key}"
    return key if ! @state.currentSubject?
    # console.log "Transcribe#translateLogicTaskKey: #{key} .. proceeding"
    task = @state.workflow.tasks[ key ]
    return key if task.tool != 'switch_on_value'

    field = task.tool_options.field
    # console.log "  Transcribe#translateLogicTaskKey Looking for ", field, @state.currentSubject
    field_value = @state.currentSubject[field]
    console.log "@state.currentSubject", @state.currentSubject
    matched_option = task.tool_options.options[field_value]
    if ! matched_option?
      console.log "WARN: SwitchOnValueTask can't find matching task \"#{field_value}\" in", task.tool_options.options
      return null

    else
      console.log "INFO: SwitchOnValue: because #{field}=\"#{field_value}\" routing to #{matched_option.task}"
      return matched_option.task

  handleTaskComplete: (ann) ->
    # console.log 'handleTaskCoplete()'
    @props.classification.annotations[@state.currentTaskKey] = ann
    # console.log "INFO Text complete: ", @props.classification.annotations

    if @state.currentTask['next_task']?
      # console.log "advance to next task...", @state.currentTask['next_task']
      @advanceToTask @state.currentTask['next_task']

    else
      @advanceToNextSubject()

  advanceToNextSubject: ->
    # console.log "next subj: ", @state.subjects, (s for s, i in @state.subjects when s['id'] == @state.currentSubject['id'])
    currentIndex = (i for s, i in @state.subjects when s['id'] == @state.currentSubject['id'])[0]
    # console.log "subjects: ", @state.subjects
    if currentIndex + 1 < @state.subjects.length
      nextSubject = @state.subjects[currentIndex + 1]
      @setState currentSubject: nextSubject, () =>
        key = @state.workflow.first_task
        @advanceToTask key
    else
      console.log "WARN: End of subjects"

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


    console.log 'COMONENT DID MOUNT'
    if @props.query.scrollX? and @props.query.scrollY?
      console.log 'SCROLLING...'
      window.scrollTo(@props.query.scrollX,@props.query.scrollY)

    console.log "Transcribe#render: ", @state
    console.log "Transcribe#render: classification: ", @props.classification
    return null unless @state.currentTask?

    # TODO: HACK HACK HACK
    return null if @state.currentTask.tool == 'switch_on_value'

    annotations = @props.annotations
    currentAnnotation = (@props.classification.annotations[@state.currentTaskKey] ||= {})
    TaskComponent = @state.currentTool
    onFirstAnnotation = currentAnnotation?.task is @props.workflow.first_task

    # console.log "Transcribe#render: tool=#{@state.currentTask.tool} TaskComponent=", TaskComponent

    nextTask = if @state.currentTask.options?[currentAnnotation.value]?
      @state.currentTask.options?[currentAnnotation.value].next_task
    else
      @state.currentTask.next_task

    # console.log "viewer size: ", @state.viewerSize
    <div className="classifier">
      <div className="subject-area">
        { if @state.noMoreSubjects
            console.log 'NO MORE SUBJECTS!!!'
            style = marginTop: "50px"
            <p style={style}>There are currently no transcription subjects. Try <a href="/#/mark">marking</a> instead!</p>
          else if @state.currentSubject?
            <SubjectViewer onLoad={@handleViewerLoad} subject={@state.currentSubject} active=true workflow={@props.workflow} classification={@props.classification} annotation={currentAnnotation}>
              <TaskComponent ref="taskComponent" viewerSize={@state.viewerSize} key={@state.currentTaskKey} task={@state.currentTask} annotation={currentAnnotation} subject={@state.currentSubject} onChange={@handleTaskComponentChange} onComplete={@handleTaskComplete} onBack={@makeBackHandler()} workflow={@props.workflow} viewerSize={@state.viewerSize} />
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

# @cjsx React.DOM
React              = require 'react'
SubjectViewer      = require '../subject-viewer'
JSONAPIClient      = require 'json-api-client' # use to manage data?
FetchSubjectsMixin = require 'lib/fetch-subjects-mixin'
ForumSubjectWidget = require '../forum-subject-widget'

# Hash of core tools:
core_tools        = require '../tasks'
# Hash of transcribe tools:
transcribe_tools   = require './tools'

resource = new JSONAPIClient

module.exports = React.createClass
  displayName: 'Transcribe'

  mixins: [FetchSubjectsMixin] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    # TODO: why is workflow an array!?!?
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
    
    tool = core_tools[task?.tool] ? transcribe_tools[task?.tool]
    if ! task?
      console.log "WARN: Invalid task key: ", key

    else if ! tool?
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
    matched_option = task.tool_options.options[field_value]
    if ! matched_option?
      console.log "WARN: SwitchOnValueTask can't find matching task \"#{field_value}\" in", task.tool_options.options
      return null

    else
      console.log "INFO: SwitchOnValue: because #{field}=\"#{field_value}\" routing to #{matched_option.task}"
      return matched_option.task

  handleTaskComplete: (ann) ->
    @props.classification.annotations[@state.currentTaskKey] = ann
    console.log "INFO Text complete: ", @props.classification.annotations

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

  handleViewerLoad: (size) ->
    # console.log "setting size: ", size
    @setState
      viewerSize: size

    if (tool = @refs.taskComponent)?
      tool.onViewerResize size
      # console.log "viewer resize: ", size, tool

  makeBackHandler: ->
    () =>
      console.log "go back"

  render: ->
    console.log "Transcribe#render: ", @state
    return null unless @state.currentSubject? && @state.currentTask?

    # TODO: HACK HACK HACK
    return null if @state.currentTask.tool == 'switch_on_value'

    annotations = @props.annotations
    currentAnnotation = (@props.classification.annotations[@state.currentTaskKey] ||= {})
    TaskComponent = @state.currentTool
    onFirstAnnotation = currentAnnotation?.task is @props.workflow.first_task

    console.log "Transcribe#render: tool=#{@state.currentTask.tool} TaskComponent=", TaskComponent

    nextTask = if @state.currentTask.options?[currentAnnotation.value]?
      @state.currentTask.options?[currentAnnotation.value].next_task
    else
      @state.currentTask.next_task

    # console.log "viewer size: ", @state.viewerSize
    <div className="classifier">
      <div className="subject-area">
        <SubjectViewer onLoad={@handleViewerLoad} viewerSize={@state.viewerSize} subject={@state.currentSubject} active=true workflow={@props.workflow} classification={@props.classification} annotation={currentAnnotation}>
          <TaskComponent ref="taskComponent" key={@state.currentTaskKey} task={@state.currentTask} annotation={currentAnnotation} subject={@state.currentSubject} onChange={@handleTaskComponentChange} onComplete={@handleTaskComplete} onBack={@makeBackHandler()} workflow={@props.workflow} viewerSize={@state.viewerSize} />
        </SubjectViewer>
      </div>
      <div className="task-area">
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
    </div>


window.React = React


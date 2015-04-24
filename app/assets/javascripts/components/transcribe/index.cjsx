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
    overrideFetchSubjectsUrl: '/fake-transcription-subjects.json'

  fetchSubjectsCallback: ->
    console.log "fetch subjects callback: ", @
    if (new_key = @translateLogicTaskKey(@state.currentTaskKey)) != @state.currentTaskKey
      console.log "change to task key: #{new_key} from #{@state.currentTaskKey}"
      @advanceToTask new_key

  componentWillMount: ->
    console.log "Transcribe#componentWillMount"
    workflow = @state.workflow
    key = @translateLogicTaskKey workflow.first_task
    @advanceToTask key
    """
    currentTask = workflow.tasks[ workflow.first_task ]

    # if @state.firstTask?
    @setState
      currentTask: currentTask
      currentTool: currentTask.tool , =>
        console.log 'first tool is: ', @state.currentTool
    """
      
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
    console.log "Transcribe#translateLogicTaskKey: #{key}"
    return key if ! @state.currentSubject?
    console.log "Transcribe#translateLogicTaskKey: #{key} .. proceeding"
    task = @state.workflow.tasks[ key ]
    return key if task.tool != 'switch_on_value'

    field = task.tool_options.field
    field_value = @state.currentSubject[field]
    matched_option = task.tool_options.options[field_value]
    if ! matched_option?
      console.log "WARN: SwitchOnValueTask can't find matching task \"#{field_value}\" in", @props.task.tool_options.options
      return null

    else
      return matched_option.task


  viewerResize: (size) ->
    if (tool = @refs.taskComponent)?
      tool.onViewerResize size
      console.log "viewer resize: ", size, tool

  render: ->
    return null unless @state.currentSubject?

    # TODO: HACK HACK HACK
    return null if @state.currentTask.tool == 'switch_on_value'

    console.log "Transcribe#render: subject=", @state.currentSubject

    annotations = @props.annotations
    currentAnnotation = if annotations.length is 0 then {} else annotations[annotations.length-1]
    """
    currentTask = @props.workflow.tasks[currentAnnotation?.task ? @props.workflow.first_task]
    console.log "current: ", @props.workflow.tasks, currentAnnotation?.task, currentTask
    """
    TaskComponent = @state.currentTool
    # core_tools[@state.currentTask.tool] ? transcribe_tools[@state.currentTask.tool]
    onFirstAnnotation = currentAnnotation?.task is @props.workflow.first_task

    console.log "Transcribe#render: tool=#{@state.currentTask.tool} TaskComponent=", TaskComponent

    nextTask = if @state.currentTask.options?[currentAnnotation.value]?
      @state.currentTask.options?[currentAnnotation.value].next_task
    else
      @state.currentTask.next_task

    <div className="classifier">
      <div className="subject-area">
        <SubjectViewer onResize={@viewerResize} subject={@state.currentSubject} active=true workflow={@props.workflow} classification={@props.classification} annotation={currentAnnotation} />
      </div>
      <div className="task-area">
        <div className="task-container">
          <TaskComponent ref="taskComponent" task={@state.currentTask} annotation={currentAnnotation} subject={@state.currentSubject} onChange={@handleTaskComponentChange} workflow={@props.workflow}/>
          <hr/>
          <nav className="task-nav">
            <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
            { if nextTask?
                <button type="button" className="continue major-button" onClick={@loadNextTask nextTask}>Next</button>
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


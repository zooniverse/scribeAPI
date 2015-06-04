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

RowFocusTool       = require '../row-focus-tool'
API                = require '../../lib/api'

module.exports = React.createClass # rename to Classifier
  displayName: 'Transcribe'
  mixins: [FetchSubjectsMixin] # load subjects and set state variables: subjects, currentSubject, classification

  getInitialState: ->
    workflow: @props.workflow

  getDefaultProps: ->
    classification: API.type('classifications').create
      name: 'Classification'
      annotations: []
      metadata: {}
    # overrideFetchSubjectsUrl: '/fake-transcription-subjects.json'

  completeClassification: ->
    # FIXME hack to translate anns hash into array:
    anns = ({key: key, value: (ann['value'] ? ann)} for key, ann of @props.classification.annotations)
    console.log "HERE WE ARE"
    console.log "HERE WE ARE"
    @props.classification.update
      completed: true
      subject_id: @state.currentSubject.id
      workflow_id: @state.workflow.id
      'metadata.finished_at': (new Date).toISOString()
      annotations: anns
    @props.classification.save()
    # @props.onComplete?()
    console.log 'CLASSIFICATION: ', @props.classification.annotations['em_transcribe_address'], @props.classification

  fetchSubjectsCallback: ->
    new_key = @state.workflow.first_task ? @state.currentSubject['type']
    @advanceToTask new_key

  handleTaskComponentChange: (val) ->

    taskOption = @state.currentTask.options[val]
    if taskOption.next_task?
      @advanceToTask taskOption.next_task

  __updateAnnotations: ->
    console.log 'UPDATE ANNOTATIONS'
    @props.classification.update 'annotations'
      # annotations: @props.classification.annotations
    @forceUpdate()

  advanceToTask: (key) ->

    console.log "Transcribe#advanceToTask(#{key})"
    # key = @translateLogicTaskKey key
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

    field = task.tool_config.field
    # console.log "  Transcribe#translateLogicTaskKey Looking for ", field, @state.currentSubject
    field_value = @state.currentSubject[field]
    console.log "@state.currentSubject", @state.currentSubject
    matched_option = task.tool_config.options[field_value]
    if ! matched_option?
      console.log "WARN: SwitchOnValueTask can't find matching task \"#{field_value}\" in", task.tool_config.options
      return null

    else
      console.log "INFO: SwitchOnValue: because #{field}=\"#{field_value}\" routing to #{matched_option.task}"
      return matched_option.task

  handleTaskComplete: (ann) ->
    # @props.classification.annotations[@state.currentTaskKey] = ann
    classification = API.type('classifications').create
      annotation: ann
      workflow_id: @state.workflow.id
      subject_id: @state.currentSubject['id']
      generates_subject_type: @state.currentTask['generates_subject_type']
      metadata:
        started_at: (new Date).toISOString() # < TODO wrong started_at time 
        finished_at: (new Date).toISOString()
      task_key: @state.currentTask.key

    classification.save()
    console.log "INFO Text complete: ", classification

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
      @setState noMoreSubjects: true

      @completeClassification()

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
    return null unless @state.currentTask?

    # annotations = @props.annotations
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
            style = marginTop: "50px"
            <p style={style}>There are currently no transcription subjects. Try <a href="/#/mark">marking</a> instead!</p>
          else if @state.currentSubject?
            console.log "~~~~~~~CURRENT STATE", @state.currentSubject
            <SubjectViewer onLoad={@handleViewerLoad} subject={@state.currentSubject} active=true workflow={@props.workflow} classification={@props.classification} annotation={currentAnnotation}>
              <TaskComponent ref="taskComponent" viewerSize={@state.viewerSize} key={@state.currentTaskKey} task={@state.currentTask} annotation={currentAnnotation} subject={@state.currentSubject} onChange={@handleTaskComponentChange} onComplete={@handleTaskComplete} onBack={@makeBackHandler()} workflow={@props.workflow} viewerSize={@state.viewerSize} transcribeTools={transcribeTools}/>
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

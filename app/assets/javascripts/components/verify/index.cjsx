# @cjsx React.DOM
React              = require 'react'
SubjectViewer      = require '../subject-viewer'
JSONAPIClient      = require 'json-api-client' # use to manage data?
FetchSubjectsMixin = require 'lib/fetch-subjects-mixin'
ForumSubjectWidget = require '../forum-subject-widget'

# Hash of core tools:
coreTools          = require 'components/core-tools'

# Hash of transcribe tools:
verifyTools   = require './tools'

API                = require '../../lib/api'

module.exports = React.createClass # rename to Classifier
  displayName: 'Verify'
  mixins: [FetchSubjectsMixin] # load subjects and set state variables: subjects, currentSubject, classification

  getDefaultProps: ->
    workflowName: 'verify'

  fetchSubjectsCallback: ->
    new_key = @state.workflow.first_task ? (k for k, v of @state.workflow.tasks)[0]
    @advanceToTask new_key

  advanceToTask: (key) ->

    task = @state.workflow.tasks[ key ]

    tool = coreTools[task?.tool] ? verifyTools[task?.tool]
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


  # copied wholesale from trancribe: (like a lot of things)
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



  render: ->
    # if @props.query.scrollX? and @props.query.scrollY?
    #   console.log 'SCROLLING...'
    #   window.scrollTo(@props.query.scrollX,@props.query.scrollY)

    # console.log "Verify#render: ", @state
    return null unless @state.currentTask?

    # TODO: HACK HACK HACK
    return null if @state.currentTask.tool == 'switch_on_value'

    # annotations = @props.annotations
    currentAnnotation = (@props.classification.annotations[@state.currentTaskKey] ||= {})
    TaskComponent = @state.currentTool
    onFirstAnnotation = currentAnnotation?.task is @activeWorkflow().first_task
    console.log "Verify#render: ..", currentAnnotation, @state

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
            <SubjectViewer onLoad={@handleViewerLoad} subject={@state.currentSubject} active=true workflow={@activeWorkflow()} classification={@props.classification} annotation={currentAnnotation}>
              <TaskComponent
                ref="taskComponent"
                viewerSize={@state.viewerSize}
                key={@state.currentTaskKey}
                task={@state.currentTask}
                annotation={currentAnnotation}
                subject={@state.currentSubject}
                onChange={@handleTaskComponentChange}
                onComplete={@handleTaskComplete}
                workflow={@activeWorkflow()}
                verifyTools={verifyTools} />
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

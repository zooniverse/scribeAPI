Classification          = require 'models/classification.coffee'

coreTools               = require 'components/core-tools'
markTools               = require 'components/mark/tools'
transcribeTools         = require 'components/transcribe/tools'

module.exports =

  # Start a new classification:
  beginClassification: ->
    console.log 'beginClassification()'
    classifications = @state.classifications
    classification = new Classification()
    classifications.push classification
    @setState
      classifications: classifications
      classificationIndex: classifications.length-1
        , =>
          window.classifications = @state.classifications # make accessible to console
          # console.log "Begin classification: ", @state.classifications
          console.log "  ann: ", c.annotation for c in @state.classifications

  # Push current classification to server:
  commitClassification: ->
    classification = @getCurrentClassification()

    classification.subject_id = @getCurrentSubject()?.id
    classification.subject_set_id = @getCurrentSubjectSet().id if @getCurrentSubjectSet()?
    classification.workflow_id = @state.workflow.id
    classification.task_key = @state.taskKey

    classification.commit()

    console.log 'COMMITTED CLASSIFICATION: ', classification
    console.log '(ALL CLASSIFICATIONS): ', @state.classifications

  # Get current classification:
  getCurrentClassification: ->
    @state.classifications[@state.classificationIndex]

  # Get current task:
  getCurrentTask: ->
    @props.workflow.tasks[@state.taskKey] # [currentAnnotation?.task]

  # Get instance of current tool:
  getCurrentTool: ->
    toolKey = @getCurrentTask()?.tool
    tool = ( coreTools[toolKey] ? markTools[toolKey] ) ? transcribeTools[toolKey]

  # Load next logical task
  advanceToNextTask: () ->
    nextTaskKey = @getNextTask()?.key
    if nextTaskKey is null
      console.log 'NOTHING LEFT TO DO'
      return
    console.log 'LOADING NEXT TASK: ', nextTaskKey

    # Commit whatever current classification is:
    @commitClassification()
    # start a new one:
    @beginClassification()

    # record where we are in workflow:
    @advanceToTask nextTaskKey

  # Get next logical task
  getNextTask: ->
    task = @props.workflow.tasks[@state.taskKey]
    # console.log "looking up next task based on current ann: ", task, task.tool_config?.options, @getCurrentClassification().annotation?.value
    if task.tool_config?.options?[@getCurrentClassification().annotation?.value]?.next_task?
      nextKey = task.tool_config.options[@getCurrentClassification().annotation.value].next_task
    else
      nextKey = @props.workflow.tasks[@state.taskKey].next_task

    @props.workflow.tasks[nextKey]

  # Advance to a named task:
  advanceToTask: (key) ->
    console.log 'advanceToTask: key = ', key
    task = @state.workflow.tasks[ key ]

    tool = coreTools[task?.tool] ? transcribeTools[task?.tool]
    if ! task?
      console.warn "WARN: Invalid task key: ", key

    else if ! tool?
      # console.log "Props", @props
      # console.log "STATE", @state
      console.warn "WARN: Invalid tool specified in #{key}: #{task.tool}"

    else
      console.log "Transcribe#advanceToTask(#{key}): tool=#{task.tool}"

      @setState
        taskKey: key
        # currentTool: tool

  # Get currently viewed subject set
  getCurrentSubjectSet: ->
    @state.subjectSets?[@state.subject_set_index]

  # Get currently viewed subject
  getCurrentSubject: ->
    subjects = null
    # If we've viewing a subject-set (i.e. Mark) let's use that subject-set's subjects
    if @getCurrentSubjectSet()?
      subjects = @getCurrentSubjectSet().subjects

    # Otherwise, since we're not viewing subject-sets, we must have an array of indiv subjects:
    else
      subjects = @state.subjects

    # It's possible we have no subjects at all, in which case fail with null:
    subjects?[@state.subject_index]




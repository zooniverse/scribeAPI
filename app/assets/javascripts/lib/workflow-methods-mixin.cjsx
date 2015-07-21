Classification          = require 'models/classification.coffee'

coreTools               = require 'components/core-tools'
markTools               = require 'components/mark/tools'
transcribeTools         = require 'components/transcribe/tools'
verifyTools             = require 'components/verify/tools'

module.exports =

  # Convenience method for selecting currently active workflow based on active controller
  activeWorkflow: ->
    return null if ! @props.project

    k = (k for w,k in @props.project.workflows when w.name == @props.workflowName)
    return null if k?.length != 1
    @props.project.workflows[k[0]]
  
  # Start a new classification (optionally initialized with given annotation hash):
  beginClassification: (annotation = {}, callback) ->
    classifications = @state.classifications
    classification = new Classification()
    classification.annotation[k] = v for k, v of annotation
    classifications.push classification
    @setState
      classifications: classifications
      classificationIndex: classifications.length-1
        , =>
          window.classifications = @state.classifications # make accessible to console
          callback() if callback?

  # Push current classification to server:
  commitClassification: ->
    console.log 'COMMITTING CLASSIFICATION... current classification: ', @getCurrentClassification()
    classification = @getCurrentClassification()
    # checking for empty classification.annotation, we don't want to commit those classifications -- AMS
    return if Object.keys(classification.annotation).length == 0

    classification.subject_id = @getCurrentSubject()?.id
    classification.subject_set_id = @getCurrentSubjectSet().id if @getCurrentSubjectSet()?
    classification.workflow_id = @activeWorkflow().id
    classification.task_key = @state.taskKey

    # Commit classification to backend
    classification.commit (classification) =>
      # Did this generate a child_subject? Update local copy:
      if classification.child_subject
        @appendChildSubject classification.subject_id, classification.child_subject

    console.log 'COMMITTED CLASSIFICATION: ', classification
    console.log '(ALL CLASSIFICATIONS): ', @state.classifications

  # Update local version of a subject with a newly acquired child_subject (i.e. after submitting a subject-generating classification)
  appendChildSubject: (subject_id, child_subject) ->
    if (s = @subjectById(subject_id))
      s.child_subjects.push $.extend({userCreated: true}, child_subject)

      # We've updated an internal object in @state.subjectSets, but framework doesn't notice, so tell it to update:
      @forceUpdate()

    else
      console.warn "WorkflowMethodsMixin#appendChildSubject: couldn't find subject by ", subject_id

  # Get a reference to the local copy of a subject by id regardless of whether viewing subject-sets or just subjects
  subjectById: (id) ->
    if @state.subjectSets?
      for set in @state.subjectSets
        for s in set.subjects
          return s if s.id == id
    else
      for s in @state.subjects
        return s if s.id == id

  # Get current classification:
  getCurrentClassification: ->
    @state.classifications[@state.classificationIndex]

  # Get current task:
  getCurrentTask: ->
    return null if ! @state.taskKey?
    console.warn "TaskKey invalid: #{@state.taskKey}. Should be: #{(k for k,v of @getTasks())}" if ! @getTasks()[@state.taskKey]?
    @getTasks()[@state.taskKey]

  getTasks: ->
    # Add completion_assessment_task to list of tasks dynamically:
    tasks = @activeWorkflow().tasks
    if @props.workflowName == 'mark'
      tasks = $.extend tasks, completion_assessment_task: @getCompletionAssessmentTask()
    tasks

  # Get instance of current tool:
  getCurrentTool: ->
    toolKey = @getCurrentTask()?.tool
    tool = @toolByKey toolKey

  toolByKey: (toolKey) ->
    ( ( coreTools[toolKey] ? markTools[toolKey] ) ? transcribeTools[toolKey] ) ? verifyTools[toolKey]

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
    @beginClassification {}

    # After classification ready with empty annotation, proceed to next task:
    @advanceToTask nextTaskKey

  # Get next logical task
  getNextTask: ->
    task = @getTasks()[@state.taskKey]
    # console.log "looking up next task based on current ann: ", task, task.tool_config?.options, @getCurrentClassification().annotation?.value
    if task.tool_config?.options?[@getCurrentClassification().annotation?.value]?.next_task?
      nextKey = task.tool_config.options[@getCurrentClassification().annotation.value].next_task
    else
      nextKey = @getTasks()[@state.taskKey].next_task

    @getTasks()[nextKey]

  # Advance to a named task:
  advanceToTask: (key) ->
    task = @getTasks()[ key ]

    tool = @toolByKey task?.tool
    if ! task?
      console.warn "WARN: Invalid task key: ", key

    else if ! tool?
      console.warn "WARN: Invalid tool specified in #{key}: #{task.tool}"

    else
      console.log "Transcribe#advanceToTask(#{key}): tool=#{task.tool}"

      @setState
        taskKey: key

  # Get currently viewed subject set
  getCurrentSubjectSet: ->
    if @state.subjectSets?[@state.subject_set_index]
      @state.subjectSets?[@state.subject_set_index]
    else @state.subjectSets #having a hard time accounting for one subject_set

  # Get currently viewed subject
  getCurrentSubject: ->
    # If we've viewing a subject-set (i.e. Mark) let's use that subject-set's subjects

    if @getCurrentSubjectSet()?
      console.log "SUBJECT SET FOUND"
      subjects = @getCurrentSubjectSet().subjects

    # Otherwise, since we're not viewing subject-sets, we must have an array of indiv subjects:
    else
      subjects = @state.subjects

    # It's possible we have no subjects at all, in which case fail with null:
    return null unless subjects?
    subjects[@state.subject_index] # otherwise, return subject

  getCompletionAssessmentTask: ->
    generates_subject_type: null
    instruction: "Is there anything left to #{@props.workflowName}?"
    key: "completion_assessment_task"
    next_task: null
    tool: "pickOne"
    tool_config: {
        "options": {
            "complete_subject": {
                "label": "No",
                "next_task": null
            },
            "incomplete_subject": {
                "label": "Yes",
                "next_task": null
            }
        }
    }
    subToolIndex: 0

  advanceToNextSubject: ->
    if @state.subject_index + 1 < @state.subjects.length
      next_index = @state.subject_index + 1
      next_subject = @state.subjects[next_index]
      @setState
        taskKey: next_subject.type
        subject_index: next_index, =>
          key = @getCurrentSubject().type
          @advanceToTask key

    # Haz more pages of subjects?
    else if @state.subjects_next_page?
      @fetchSubjects @activeWorkflow().id, @activeWorkflow().subject_fetch_limit, @state.subjects_next_page

    else
      @setState
        subject_index: null
        noMoreSubjects: true

  commitClassificationAndContinue: (d) ->
    @commitClassification()
    @beginClassification {}, () =>
      if @getCurrentTask().next_task?
        console.log "advance to next task ann cleared: ", @getCurrentClassification().annotation, @state.classifications
        @advanceToTask @getCurrentTask().next_task

      else
        @advanceToNextSubject()

Classification          = require 'models/classification.coffee'

coreTools               = require 'components/core-tools'
markTools               = require 'components/mark/tools'
transcribeTools         = require 'components/transcribe/tools'
verifyTools             = require 'components/verify/tools'

module.exports =

  # Convenience method for selecting currently active workflow based on active controller
  getActiveWorkflow: ->
    return null if ! @props.project

    k = (k for w,k in @props.project.workflows when w.name == @props.workflowName)
    return null if k?.length != 1
    @props.project.workflows[k[0]]

  getWorkflowByName: (name) ->
    k = (k for w,k in @props.project.workflows when w.name is name)
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

  toggleBadSubject: (e, callback) ->
    @setState badSubject: not @state.badSubject, =>
      callback?()


  toggleIllegibleSubject: (e, callback) ->
    @setState illegibleSubject: not @state.illegibleSubject, =>
      callback?()

  # Push current classification to server:
  commitClassification: ->
    console.log 'COMMITTING CLASSIFICATION: ', @getCurrentClassification()
    classification = @getCurrentClassification()
    # checking for empty classification.annotation, we don't want to commit those classifications -- AMS

    classification.subject_id = @getCurrentSubject()?.id
    classification.subject_set_id = @getCurrentSubjectSet().id if @getCurrentSubjectSet()?
    classification.workflow_id = @getActiveWorkflow().id

    # If user activated 'Bad Subject' button, override task:
    if @state.badSubject
      classification.task_key = 'flag_bad_subject_task'

    else if @state.illegibleSubject
      classification.task_key = 'flag_illegible_subject_task'

    # Otherwise, classification is for active task:
    else
      classification.task_key = @state.taskKey
      return if Object.keys(classification.annotation).length == 0

    # Commit classification to backend
    classification.commit (classification) =>
      # Did this generate a child_subject? Update local copy:
      if classification.child_subject
        @appendChildSubject classification.subject_id, classification.child_subject

      if @state.badSubject
        @toggleBadSubject =>
          @advanceToNextSubject()

      if @state.illegibleSubject
        @toggleIllegibleSubject =>
          @advanceToNextSubject()

      @beginClassification()

    console.log 'COMMITTED CLASSIFICATION: ', classification
    console.log '(ALL CLASSIFICATIONS): ', @state.classifications


  # Update local version of a subject with a newly acquired child_subject (i.e. after submitting a subject-generating classification)
  appendChildSubject: (subject_id, child_subject) ->
    if (s = @getSubjectById(subject_id))
      s.child_subjects.push $.extend({userCreated: true}, child_subject)

      # We've updated an internal object in @state.subjectSets, but framework doesn't notice, so tell it to update:
      @forceUpdate()

    else
      console.warn "WorkflowMethodsMixin#appendChildSubject: couldn't find subject by ", subject_id

  # Get a reference to the local copy of a subject by id regardless of whether viewing subject-sets or just subjects
  getSubjectById: (id) ->
    if @state.subjectSets?
      for s in @getCurrentSubjectSet().subjects
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
# <<<<<<< HEAD
    tasks = @getActiveWorkflow().tasks
    completion_assessment_task = @getCompletionAssessmentTask()
    # Merge keys recursively if it exists in config
    completion_assessment_task = $.extend true, tasks['completion_assessment_task'], completion_assessment_task if tasks['completion_assessment_task']?
    $.extend tasks, completion_assessment_task: completion_assessment_task
# =======
#     tasks = @getActiveWorkflow().tasks
#     if @props.workflowName == 'mark'
#       tasks = $.extend tasks, completion_assessment_task: @getCompletionAssessmentTask()
#     tasks
# >>>>>>> master

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
    # PB: Moving from hash of options to an array of options
    if (options = (c for c in task.tool_config?.options when c.value == @getCurrentClassification().annotation?.value)) && options.length > 0 && (opt = options[0])? && opt.next_task?
      nextKey = opt.next_task
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
      subjects = @getCurrentSubjectSet().subjects

    # Otherwise, since we're not viewing subject-sets, we must have an array of indiv subjects:
    else
      subjects = @state.subjects

    # It's possible we have no subjects at all, in which case fail with null:
    return null unless subjects?
    subjects[@state.subject_index] # otherwise, return subject

  getCompletionAssessmentTask: ->
    generates_subject_type: null
    instruction: "Thanks for all your work! Is there anything left to #{@props.workflowName}?"
    key: "completion_assessment_task"
    next_task: null
    tool: "pickOne"
    help: {
      title: "Completion Assessment",
      body: "You do not have to complete every page, but it helps us to know, before you move on to another task, if there is any work left to do. Thanks again!"
    },
    tool_config: {
      "options": [
        {
          "label": "No",
          "next_task": null,
          "value": "complete_subject"
        },
        {
          "label": "Yes",
          "next_task": null,
          "value": "incomplete_subject"
        }
      ]
    }
    subToolIndex: 0

  # Regardless of what workflow we're in, call this to display next subject (if any avail)
  advanceToNextSubject: ->
    if @state.subjects?
      @_advanceToNextSubjectInSubjects()
    else
      @_advanceToNextSubjectInSubjectSets()

  # This is the version of advanceToNextSubject for workflows that consume subjects (transcribe,verify)
  _advanceToNextSubjectInSubjects: ->
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
      @fetchSubjects @getActiveWorkflow().id, @getActiveWorkflow().subject_fetch_limit, @state.subjects_next_page

    else
      @setState
        subject_index: null
        userClassifiedAll: @state.subjects.length > 0

  # This is the version of advanceToNextSubject for workflows that consume subject sets (mark)
  _advanceToNextSubjectInSubjectSets: ->
    new_subject_set_index = @state.subject_set_index
    new_subject_index = @state.subject_index + 1

    # If we've exhausted pages in this subject set, move to next one:
    if new_subject_index >= @getCurrentSubjectSet().subjects.length
      new_subject_set_index += 1
      new_subject_index = 0

    # If we've exhausted all subject sets, collapse in shame
    if new_subject_set_index >= @state.subjectSets.length
      @setState
        notice:
          header: "All Done!"
          message: "There's nothing more to #{@props.workflowName} here."
          onClick: "/#/mark"
      console.warn "NO MORE SUBJECT SETS"
      return

    console.log "Mark#index Advancing to subject_set_index #{new_subject_set_index} (of #{@state.subjectSets.length}), subject_index #{new_subject_index} (of #{@state.subjectSets[new_subject_set_index].subjects.length})"

    @setState
      subject_set_index: new_subject_set_index
      subject_index: new_subject_index
      taskKey: @getActiveWorkflow().first_task
      currentSubToolIndex: 0


  commitClassificationAndContinue: (d) ->
    @commitClassification()
    @beginClassification {}, () =>
      if @getCurrentTask().next_task?
        @advanceToTask @getCurrentTask().next_task

      else
        @advanceToNextSubject()

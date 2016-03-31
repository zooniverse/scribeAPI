React     = require 'react'
HelpModal = require './help-modal'
DraggableModal  = require 'components/draggable-modal'

module.exports = React.createClass
  displayName: 'Tutorial'

  propTypes:
    tutorial: React.PropTypes.object.isRequired
    onCloseTutorial: React.PropTypes.func.isRequired

  getInitialState:->
    currentTask: @props.tutorial.first_task
    nextTask: @props.tutorial.tasks[@props.tutorial.first_task].next_task
    completedSteps: 0
    doneButtonLabel: "Next"

  advanceToNextTask:->
    if @props.tutorial.tasks[@state.currentTask].next_task == null
      @onClose()

    else
      @setState
        currentTask: @state.nextTask
        nextTask: @props.tutorial.tasks[@state.nextTask].next_task
        completedSteps: @state.completedSteps + 1

  onClose: ->
    @animateClose()
    @props.onCloseTutorial()

  animateClose: ->
    $modal = $(@refs.tutorialModal.getDOMNode())
    $clone = $modal.clone()
    $link = $('.tutorial-link').first()
    if $link.length
      x1 = $modal.offset().left - $(window).scrollLeft()
      y1 = $modal.offset().top - $(window).scrollTop()
      x2 = $link.offset().left - $(window).scrollLeft()
      y2 = $link.offset().top - $(window).scrollTop()
      xdiff = x2 - x1
      ydiff = y2 - y1
      $modal.parent().append($clone)
      $clone.animate {
          opacity: 0
          left: '+=' + xdiff
          top: '+=' + ydiff
          width: 'toggle'
          height: 'toggle'
        }, 500, ->
          $clone.remove()

  onClickStep: (index) ->
    taskKeys = Object.keys(@props.tutorial.tasks)
    taskKey = taskKeys[index]
    task = @props.tutorial.tasks[taskKey]
    @setState
      currentTask: taskKey
      nextTask: task.next_task
      completedSteps: index

  render:->
    helpContent = @props.tutorial.tasks[@state.currentTask].help
    taskKeys = Object.keys(@props.tutorial.tasks)

    if @state.nextTask != null
      doneButtonLabel = "Next"
    else
      doneButtonLabel = "Done"

    progressSteps = []
    for key, step of @props.tutorial.tasks
      progressSteps.push step

    <DraggableModal ref="tutorialModal" header={helpContent.title ? 'Help'} doneButtonLabel={doneButtonLabel} onDone={@advanceToNextTask} width={800} classes="help-modal" currentStepIndex={@state.completedSteps} closeButton=true onClose={@onClose} progressSteps={progressSteps} onClickStep={@onClickStep} >
      <div dangerouslySetInnerHTML={{__html: marked( helpContent.body ) }} />
    </DraggableModal>

React     = require 'react'
HelpModal = require './help-modal'
DraggableModal  = require 'components/draggable-modal'


module.exports = React.createClass
  displayName: 'Tutorial'

  propTypes:
    tutorial: React.PropTypes.object.isRequired
    toggleTutorial: React.PropTypes.func.isRequired

  getInitialState:->
    currentTask: @props.tutorial.first_task
    nextTask: @props.tutorial.tasks[@props.tutorial.first_task].next_task
    completedSteps: 0

  setCompleteTutorial:->
    request = $.getJSON "/tutorial_complete"

    request.done (result)=>
      @props.toggleTutorial()

    request.fail (error)=>
      console.log "failed to set tutorial value for user"


  advanceToNextTask:->
    if @props.tutorial.tasks[@state.currentTask].next_task == null
      @setCompleteTutorial()

    else
      @setState 
        currentTask: @state.nextTask
        nextTask: @props.tutorial.tasks[@state.nextTask].next_task
        completedSteps: @state.completedSteps + 1

  render:->
    helpContent = @props.tutorial.tasks[@state.currentTask].help
    taskKeys = Object.keys(@props.tutorial.tasks)

    <DraggableModal header={helpContent.title ? 'Help'} onDone={@advanceToNextTask} width=600 classes="help-modal" progressSteps={taskKeys} currentStepIndex={@state.completedSteps} >
      <div dangerouslySetInnerHTML={{__html: marked( helpContent.body ) }} />
    </DraggableModal>
      

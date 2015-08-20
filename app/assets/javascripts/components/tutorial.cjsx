React     = require 'react'
HelpModal = require './help-modal'
DraggableModal  = require 'components/draggable-modal'


module.exports = React.createClass
  displayName: 'Tutorial'

  propTypes:
    tutorial: React.PropTypes.object.isRequired

  getInitialState:->
    currentTask: @props.tutorial.first_task
    nextTask: @props.tutorial.tasks[@props.tutorial.first_task].next_task
    completedSteps: 1

  advanceToNextTask:->
    if @props.tutorial.tasks[@state.currentTask].next_task == null
      console.log "END OF TUTORIAL"
    else

      @setState 
        currentTask: @state.nextTask
        nextTask: @props.tutorial.tasks[@state.nextTask].nextTask
        completedSteps: @state.completedSteps + 1

  render:->
    helpContent = @props.tutorial.tasks[@state.currentTask].help
    taskKeys = Object.keys(@props.tutorial.tasks)

    <DraggableModal header={helpContent.title ? 'Help'} onDone={@advanceToNextTask} width=600 classes="help-modal" progressSteps={taskKeys} completedSteps={@state.completedSteps} >
      <div dangerouslySetInnerHTML={{__html: marked( helpContent.body ) }} />
    </DraggableModal>
      

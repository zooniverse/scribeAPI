React     = require 'react'
HelpModal = require './help-modal'


module.exports = React.createClass
  displayName: 'Tutorial'

  propTypes:
    tutorial: React.PropTypes.object.isRequired

  getInitialState:->
    currentTask: @props.tutorial.first_task
    nextTask: @props.tutorial.tasks[@props.tutorial.first_task].next_task

  advanceToNextTask:->
    if @props.tutorial.tasks[@state.currentTask].next_task == null
      console.log "END OF TUTORIAL"
    else

      @setState 
        currentTask: @state.nextTask
        nextTask: @props.tutorial.tasks[@state.nextTask].nextTask

  render:->
    helpContent = @props.tutorial.tasks[@state.currentTask].help
    <HelpModal help={helpContent} onDone={@advanceToNextTask} />

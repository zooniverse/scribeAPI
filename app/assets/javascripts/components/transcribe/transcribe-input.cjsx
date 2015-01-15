# @cjsx React.DOM
React = require 'react'

TranscribeInput = React.createClass
  displayName: 'TranscribeInput'

  render: ->
    # console.log 'TASK: ', @props.task
    if @props.task.key is @props.currentStep
      classes = 'input-field active'
    else
      classes = 'input-field'

    <div className={classes}>
      { 
        unless @props.task.type is "textarea"
          <div>
            <label>{@props.task.instruction}</label>
            <input 
              className   = "transcribe-input" 
              type        = {@props.task.type} 
              placeholder = {@props.task.label} 
            />
          </div>
        else
          <textarea className="transcribe-input" placeholder={@props.task.instruction} />
      }
    </div>
      
module.exports = TranscribeInput
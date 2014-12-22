# @cjsx React.DOM
React = require 'react'

TranscribeInput = React.createClass
  displayName: 'TranscribeInput'

  render: ->
    if @props.step.key is @props.currentStep
      classes = 'input-field active'
    else
      classes = 'input-field'

    <div className={classes}>
      { 
        unless @props.step.type is "textarea"
          <div>
            <label>{@props.step.instruction}</label>
            <input 
              className   = "transcribe-input" 
              type        = {@props.step.type} 
              placeholder = {@props.step.label} 
            />
          </div>
        else
          <textarea className="transcribe-input" placeholder={@props.step.instruction} />
      }
    </div>
      
module.exports = TranscribeInput
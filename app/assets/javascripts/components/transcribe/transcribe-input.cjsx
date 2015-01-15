# @cjsx React.DOM
React = require 'react'

TranscribeInput = React.createClass
  displayName: 'TranscribeInput'

  componentWillReceiveProps: ->
    console.log 'PROPS ASHA: ', @props

  render: ->
    if @props.step.key is @props.currentStep
      classes = 'input-field active'
      console.log 'INACTIVE'
    else
      classes = 'input-field'
      console.log 'ACTIVE'

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
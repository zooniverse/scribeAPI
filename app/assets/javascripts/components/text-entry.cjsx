# @cjsx React.DOM
React = require 'react'
Draggable = require '../lib/draggable'

TextEntryTool = React.createClass
  displayName: 'TextEntryTool'

  getInitialState: ->
    console.log 'TRANSCRIBE STEPS: ', @props.transcribeSteps
    currentStep: 0
    finished: false


  handleTranscription: ->
    return unless @nextStepAvailable()
    console.log 'handleTranscription()'
    @setState currentStep: @state.currentStep + 1

  nextStep: ->
    console.log 'nextStep()'
    return unless @nextStepAvailable()

  prevStep: ->
    console.log 'prevStep()'
    return unless @prevStepAvailable

  nextStepAvailable: ->
    if @state.currentStep + 1 > @props.transcribeSteps.length - 1
      console.log 'THERE IS NO NEXT STEP'
      return false
    else
      console.log 'NEXT STEP...'
      return true

  prevStepAvailable: ->
    if @state.currentStep - 1 >= 0
      console.log 'PREV STEP...'
      return true
    else
      console.log 'THERE IS NO PREV STEP'
      return false

  render: ->

    console.log 'render()'
    currentStep = @state.currentStep

    <div className="text-entry">
      <div className="left">
        <div className="input-field state text">
          <input 
            type="text" 
            placeholder={@props.transcribeSteps[currentStep].label} 
            className="transcribe-input" 
            role="textbox" 
          />
          <label>{@props.transcribeSteps[currentStep].description}</label>
        </div>
      </div>
      <div className="right">
        <a className="blue button back">Back</a>
        <a className="red button skip">Skip</a>
        <a className="white button finish" onClick={@handleTranscription}>Done</a>
      </div>
    </div>

module.exports = TextEntryTool
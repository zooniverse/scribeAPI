# @cjsx React.DOM
React = require 'react'
Draggable = require '../lib/draggable'

TextEntryTool = React.createClass
  displayName: 'TextEntryTool'

  componentWillReceiveProps: ->


  getInitialState: ->
    console.log 'TRANSCRIBE STEPS: ', @props.transcribeSteps
    currentStep: 0
    finished: false

  handleTranscription: ->
    console.log 'handleTranscription()'
    field_name = @props.transcribeSteps[@state.currentStep].field_name
    field_data = $('.transcribe-input').val()
    @props.recordTranscription(field_name, field_data)
    @setState currentStep: @state.currentStep + 1

  nextStep: ->
    return unless @nextStepAvailable()
    @setState currentStep: @state.currentStep + 1

  prevStep: ->
    return unless @prevStepAvailable()
    @setState currentStep: @state.currentStep - 1

  nextStepAvailable: ->
    if @state.currentStep + 1 > @props.transcribeSteps.length - 1
      # console.log 'THERE IS NO NEXT STEP'
      return false
    else
      # console.log 'NEXT STEP...'
      return true

  prevStepAvailable: ->
    if @state.currentStep - 1 >= 0
      # console.log 'PREV STEP...'
      return true
    else
      # console.log 'THERE IS NO PREV STEP'
      return false

  render: ->
    console.log 'render()'
    currentStep = @state.currentStep

    if @prevStepAvailable()
      prev_button = <a className="blue button back" onClick={@prevStep}>&lt;</a>
    else
      prev_button = <a className="blue button back disabled">&lt;</a>

    if @nextStepAvailable()
      next_button = <a className="red button back" onClick={@nextStep}>&gt;</a>
      done_button = <a className="green button finish" onClick={@handleTranscription}>Done</a>
    else
      next_button = <a className="red button back disabled">&gt;</a>
      done_button = <a className="green button finish" onClick={@props.nextTextEntry}>Next Entry</a>


    <div className="text-entry">
      <div className="left">
        <div className="input-field state text">
          <label value="FOO">{@props.transcribeSteps[currentStep].description}</label>
          <input 
            type="date" 
            placeholder={@props.transcribeSteps[currentStep].label} 
            className="transcribe-input" 
            role="textbox" 
          />
        </div>
      </div>
      <div className="right">
        {prev_button}
        {next_button}
        {done_button}
      </div>
    </div>

module.exports = TextEntryTool
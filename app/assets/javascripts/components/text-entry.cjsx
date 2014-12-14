# @cjsx React.DOM
React = require 'react'
Draggable = require '../lib/draggable'

TextEntryTool = React.createClass
  displayName: 'TextEntryTool'

  getInitialState: ->
    currentStep: @props.transcribeSteps[0]

  componentWillReceiveProps: ->
    console.log 'TRANSCRIBE STEPS: ', @props.transcribeSteps
    return
    # console.log 'RECEIVING PROPS...'
    @setProps
      # not in use (anymore)
      top: @props.top 
      left: @props.left
    
  render: ->

    <div className="text-entry">
      <div className="left">
        <div className="input-field state text">
          <input 
            type="text" 
            placeholder={@state.currentStep.label} 
            className="transcribe-input" 
            role="textbox" 
          />
          <label>{@state.currentStep.description}</label>
        </div>
      </div>
      <div className="right">
        <a className="blue button back">Back</a>
        <a className="red button skip">Skip</a>
        <a className="white button finish">Done</a>
      </div>
    </div>

module.exports = TextEntryTool
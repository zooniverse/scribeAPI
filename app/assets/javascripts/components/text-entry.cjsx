# @cjsx React.DOM
React = require 'react'
Draggable = require '../lib/draggable'

TextEntryTool = React.createClass
  displayName: 'TextEntryTool'

  componentWillReceiveProps: ->
    console.log 'TRANSCRIBE STEPS: ', @props.transcribeSteps
    return
    # console.log 'RECEIVING PROPS...'
    @setProps
      # not in use (anymore)
      top: @props.top 
      left: @props.left
    
  render: ->

    # style =
    #   top: "#{@props.top}"
    #   left: "#{@props.left}"

    <div className="text-entry">
      <div className="left">
        <div className="input_field state text">

          <input 
            type="text" 
            placeholder={@props.label} 
            className="" 
            role="textbox" 
          />
        </div>
      </div>
      <div className="right">
        <a className="blue button back">Back</a>
        <a className="red button skip">Skip</a>
        <a className="white button finish">Done</a>
      </div>
    </div>

module.exports = TextEntryTool
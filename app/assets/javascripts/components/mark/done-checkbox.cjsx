# @cjsx React.DOM

React = require 'react'

module.exports = React.createClass
  displayName: 'DoneCheckbox'

  getInitialState: ->
    fillColor: 'rgba(100,200,50,0.2)'
    strokeColor: 'rgb(0,0,0)'
    strokeWidth: 4
    borderRadius: 10
    width: 200
    height: 40

    markComplete: false
    transcribeComplete: false

    buttonLabel: "SUBMIT"

  componentWillReceiveProps: ->
    @setState
      markComplete: @props.markComplete
      transcribeComplete: @props, =>
        console.log 'transcribeComplete = ', @props.transcribeComplete
        if @props.markComplete and not @props.transcribeComplete 
          @setState 
            # fillColor: 'rgba(100,200,50,1.0)'
            buttonLabel: "TRANSCRIBE"
        if @props.markComplete and @props.transcribeComplete
          @setState 
            fillColor: 'rgba(100,200,50,1.0)'
            buttonLabel: 'COMPLETE!'

  render: ->
    <g 
      onClick     = {@props.handleToolProgress}
      transform   = {@props.transform} 
      className   = "clickable drawing-tool-done-button" 
      stroke      = {@state.strokeColor} 
      strokeWidth = {@state.strokeWidth} >
      <rect 
        transform = "translate(0,-5)"
        rx        = "#{@state.borderRadius}" 
        ry        = "#{@state.borderRadius}" 
        width     = "#{@state.width}" 
        height    = "#{@state.height}" 
        fill      = "#{@state.fillColor}" />
      <text

        transform = "translate(12,24)"
        fontSize  = "26">
        {@state.buttonLabel}
      </text>
    </g>
# @cjsx React.DOM
React = require 'react'
Draggable = require '../lib/draggable'

TextEntryTool = React.createClass
  displayName: 'TextEntryTool'

  getInitialState: ->
    console.log 'PROPS:', @props
    currentStep: 0
    dx: 0
    dy: 0

  # componentWillReceiveProps: ->

  handleTranscription: ->
    console.log 'handleTranscription()'

    transcription = []
    for step, i in @props.transcribeSteps
      transcription.push { field_name: "#{step.field_name}", value: $(".transcribe-input:eq(#{step.key})").val() }

    # field_name = @props.transcribeSteps[@state.currentStep].field_name
    # field_data = $('.transcribe-input').val()

    @props.recordTranscription(transcription)
    @setState currentStep: 0

  nextStep: (e) ->
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

  handleInitStart: (e) ->
    console.log 'handleInitStart() '
    console.log 'TARGET: ', e.target.nodeName
    @setState preventDrag: false
    if e.target.nodeName is "INPUT"
      @setState preventDrag: true
      
    console.log "[left, top] = [#{@state.dx}, #{@state.dy}]"

    @setState
      xClick: e.pageX - $('.text-entry').offset().left
      yClick: e.pageY - $('.text-entry').offset().top

  handleInitDrag: (e) ->
    # # DEBUG CODE
    # console.log 'handleInitDrag()'
    # console.log 'OFFSET: ', $('.text-entry').offset()

    return if @state.preventDrag
    
    dx = e.pageX - @state.xClick
    dy = e.pageY - @state.yClick

    @setState
      dx: dx
      dy: dy , =>
        console.log "DRAG: [left, top] = [#{@state.dx}, #{@state.dy}]"

  handleInitRelease: ->
    # console.log 'handleInitRelease()'

  render: ->
    # console.log 'render()'
    currentStep = @state.currentStep

    if @prevStepAvailable()
      prev_button = <a className="blue button back" onClick={@prevStep}>&lt; Back</a>
    else
      prev_button = <a className="blue button back disabled">&lt; Back</a>

    if @nextStepAvailable()
      next_button = <a className="red button back" onClick={@nextStep}>Skip &gt;</a>
      # done_button = <a className="green button finish" onClick={@handleTranscription}>Done</a>
    else
      next_button = <a className="red button back disabled">Skip &gt;</a>
      # done_button = <a className="green button finish" onClick={@props.nextTextEntry}>Next Entry</a>

    done_button = <a className="green button finish" onClick={@handleTranscription}>Done</a>

    style = 
      left: @state.dx,
      top:  @state.dy

    <div className="text-entry-container">
      <Draggable
        onStart = {@handleInitStart}
        onDrag  = {@handleInitDrag}
        onEnd   = {@handleInitRelease}>

        <div className="text-entry" style={style}>
          <div className="left">
            {
              for step in @props.transcribeSteps
                if step.key is @state.currentStep
                  class_name = 'input-field active'
                else
                  class_name = 'input-field'
                
                <div className={class_name}>
                  <label>{step.instruction}</label>
                  <input 
                    className="transcribe-input" 
                    type={step.type} 
                    placeholder={step.label} 
                  />
                </div>
            }
          </div>
          <div className="right">
            {prev_button}
            {next_button}
            {done_button}
          </div>
        </div>
      </Draggable>
    </div>

module.exports = TextEntryTool
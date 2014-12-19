# @cjsx React.DOM
React = require 'react'
Draggable  = require '../../lib/draggable'
PrevButton = require './prev-button'
NextButton = require './next-button'
# DoneButton = require './done-button'

TranscribeTool = React.createClass
  displayName: 'TranscribeTool'

  getInitialState: ->
    console.log 'PROPS:', @props
    currentStep: 0
    dx: window.innerWidth/2 - 200
    dy: @props.scale.vertical * @props.selectedMark.yLower + 20
    
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

  nextTextEntry: ->
    console.log 'next step available? ', @nextStepAvailable()
    @setState
      currentStep: 0
      dx: window.innerWidth/2 - 200
      dy: @props.scale.vertical * @props.selectedMark.yLower + 20, =>
        @props.nextTextEntry()

  nextStep: (e) ->
    console.log 'nextStep()'
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
      console.log 'PREV STEP...'
      return true
    else
      console.log 'THERE IS NO PREV STEP'
      return false

  handleInitStart: (e) ->
    console.log 'handleInitStart() '
    console.log 'TARGET: ', e.target.nodeName
    @setState preventDrag: false
    if e.target.nodeName is "INPUT"
      @setState preventDrag: true
      
    console.log "[left, top] = [#{@state.dx}, #{@state.dy}]"

    @setState
      xClick: e.pageX - $('.transcribe-tool').offset().left
      yClick: e.pageY - $('.transcribe-tool').offset().top

  handleInitDrag: (e) ->
    # # DEBUG CODE
    # console.log 'handleInitDrag()'
    # console.log 'OFFSET: ', $('.transcribe-tool').offset()

    return if @state.preventDrag

    dx = e.pageX - @state.xClick - window.scrollX
    dy = e.pageY - @state.yClick - window.scrollY

    @setState
      dx: dx
      dy: dy #, =>
        # console.log "DRAG: [left, top] = [#{@state.dx}, #{@state.dy}]"

  handleInitRelease: ->
    # console.log 'handleInitRelease()'

  render: ->
    # console.log 'render()'
    currentStep = @state.currentStep
    
    style = 
      left: @state.dx,
      top:  @state.dy

    <div className="transcribe-tool-container">
      <Draggable
        onStart = {@handleInitStart}
        onDrag  = {@handleInitDrag}
        onEnd   = {@handleInitRelease}>

        <div className="transcribe-tool" style={style}>
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
            <PrevButton prevStepAvailable = {@prevStepAvailable} prevStep = {@prevStep} />
            <NextButton nextStepAvailable = {@nextStepAvailable} nextStep = {@nextStep}/>
          </div>
        </div>
      </Draggable>
    </div>

module.exports = TranscribeTool
# @cjsx React.DOM
React = require 'react'
Draggable       = require '../../lib/draggable'
PrevButton      = require './prev-button'
NextButton      = require './next-button'
DoneButton      = require './done-button'
TranscribeInput = require './transcribe-input'

TranscribeTool = React.createClass
  displayName: 'TranscribeTool'

  componentWillReceiveProps: ->
    console.log 'componentDidReceiveProps() ', @props
    for step in [ @props.tasks... ]
      console.log 'STEP: ', step

  getInitialState: ->
    console.log 'yLower: ', @props.selectedMark.yLower
    currentStep: 0
    dx: window.innerWidth/2 - 200
    dy: @props.scale.vertical * @props.selectedMark.yLower + 20

  nextTextEntry: ->
    @setState
      currentStep: 0
      dx: window.innerWidth/2 - 200
      dy: @props.scale.vertical * @props.selectedMark.yLower + 20, =>
        @props.nextTextEntry()

  nextStep: (e) ->
    # record transcription
    transcription = []
    
    for step, i in @props.tasks
      transcription.push { 
        field_name: "#{step.field_name}", 
        value: $(".transcribe-input:eq(#{step.key})").val() 
      }

    @props.recordTranscription(transcription)
    
    if @nextStepAvailable
      currentStep = @state.currentStep + 1
    else
      currentStep = 0

    @setState currentStep: currentStep
    
  prevStep: ->
    return unless @prevStepAvailable()
    @setState currentStep: @state.currentStep - 1

  nextStepAvailable: ->
    if @state.currentStep + 1 > @props.tasks.length - 1
      # console.log 'THERE IS NO NEXT STEP'
      return false
    else
      # console.log 'NEXT STEP...'
      return true

  prevStepAvailable: ->
    if @state.currentStep - 1 >= 0
      return true
    else
      return false

  handleInitStart: (e) ->
    # console.log 'handleInitStart() '
    # console.log 'TARGET: ', e.target.nodeName
    @setState preventDrag: false
    if e.target.nodeName is "INPUT" or e.target.nodeName is "TEXTAREA"
      @setState preventDrag: true
      
    console.log "[left, top] = [#{@state.dx}, #{@state.dy}]"

    @setState
      xClick: e.pageX - $('.transcribe-tool').offset().left
      yClick: e.pageY - $('.transcribe-tool').offset().top

  handleInitDrag: (e) ->
    # # DEBUG CODE
    # console.log 'handleInitDrag()'
    # console.log 'OFFSET: ', $('.transcribe-tool').offset()

    return if @state.preventDrag # not too happy about this one

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

    console.log "[left, top] = [#{@state.dx}, #{@state.dy}]"
    
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
              for key, task of @props.tasks # NOTE: remember tasks is Object
                <TranscribeInput task = {task} currentStep = {@state.currentStep} />
            }
          </div>
          <div className="right">
            <PrevButton prevStepAvailable = {@prevStepAvailable} prevStep = {@prevStep} />
            <NextButton nextStepAvailable = {@nextStepAvailable} nextStep = {@nextStep} />
            <DoneButton nextStepAvailable = {@nextStepAvailable} nextTextEntry = {@nextTextEntry} />
          </div>
        </div>
      </Draggable>
    </div>

module.exports = TranscribeTool
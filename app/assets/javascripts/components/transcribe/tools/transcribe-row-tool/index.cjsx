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
    
    @setState
      dx: window.innerWidth/2 - 200
      dy: @props.yScale * @props.selectedMark.yLower + 65 - @props.scrollOffset

  getInitialState: ->    
    # convert task object to array (to use .length method)
    tasksArray = []
    for key, elem of @props.tasks
      tasksArray[key] = elem

    tasks: tasksArray
    currentStep: 0
    # dx: window.innerWidth/2 - 200
    # dy: @props.yScale * @props.selectedMark.yLower + 20

  componentDidMount: ->

  nextTextEntry: ->
    @setState
      currentStep: 0
      dx: window.innerWidth/2 - 200
      dy: @props.yScale * @props.selectedMark.yLower + 20, =>
        @props.nextTextEntry()

  nextStep: (e) ->
    # record transcription
    transcription = []
    
    for step, i in @state.tasks
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
    if @state.currentStep + 1 > @state.tasks.length - 1
      return false
    else
      return true

  prevStepAvailable: ->
    if @state.currentStep - 1 >= 0
      return true
    else
      return false

  handleInitStart: (e) ->
    @setState preventDrag: false
    if e.target.nodeName is "INPUT" or e.target.nodeName is "TEXTAREA"
      @setState preventDrag: true
      
    @setState
      xClick: e.pageX - $('.transcribe-tool').offset().left
      yClick: e.pageY - $('.transcribe-tool').offset().top

  handleInitDrag: (e) ->
    return if @state.preventDrag # not too happy about this one

    dx = e.pageX - @state.xClick - window.scrollX
    dy = e.pageY - @state.yClick - window.scrollY

    @setState
      dx: dx
      dy: dy #, =>

  handleInitRelease: ->

  render: ->
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
            { for key, task of @state.tasks # NOTE: remember tasks is Object
                <TranscribeInput key={key} task={task} currentStep={@state.currentStep} />
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
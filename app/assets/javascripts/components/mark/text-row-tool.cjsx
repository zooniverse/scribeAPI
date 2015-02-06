# @cjsx React.DOM
# Model = require '../../data/model'
React = require 'react'
Draggable = require '../../lib/draggable'
DeleteButton = require './delete-button'
ResizeButton = require './resize-button'
DoneCheckbox = require './done-checkbox'

DEBUG = false

TextRowTool = React.createClass
  displayName: 'TextRowTool'

  statics:
    defaultValues: ->
      @initStart arguments...

    initStart: ->
      @initMove arguments...

    initMove: ({x, y}) ->
      {x, y}

  getInitialState: ->
    mark: @props.mark
    markStatus: 'mark'
    fillColor: @props.fillColor
    strokeColor: @props.strokeColor
    strokeWidth: @props.strokeWidth
    locked: false

  getDefaultProps: ->
    fillColor: 'rgba(0,0,0,0.5)'
    strokeColor: 'rgba(0,0,0,0.5)'
    strokeWidth: 6

  componentWillReceiveProps: ->
    @setState 
      mark: @props.mark, =>
        @forceUpdate()

  onClickMarkButton: ->
    markStatus = @state.markStatus
    switch markStatus
      when 'mark'
        @setState 
          markStatus: 'mark-finished'
          locked: false
        @props.submitMark(@props.key)
        console.log 'Mark submitted. Click TRANSCRIBE to begin transcribing.'
      when 'mark-finished'
        @setState 
          markStatus: 'transcribe'
          locked: true
        @props.onClickTranscribe(@state.mark.key)
        # @transcribeMark(mark)

        console.log 'Going into TRANSCRIBE mode. Stand by.'
      when 'transcribe'
        @setState 
          markStatus: 'transcribe-finished'
          locked: true
        # @submitTranscription()
        console.log 'Transcription submitted.'
      when 'transcribe-finished'
        @setState locked: true
        console.log 'All done. Nothing left to do here.'
      else
        @setState locked: true
        console.log 'WARNING: Unknown state in handleToolProgress()'

  render: ->

    classString = 'point drawing-tool'

    unless @state.markStatus is 'mark'
      markDragHandler = null
      classString += ' locked'
    else
      markDragHandler = @props.handleDragMark

    markHeight = @state.mark.yLower - @state.mark.yUpper

    <g 
      className = {classString} 
      transform = {"translate(#{Math.ceil @state.strokeWidth}, #{Math.round( @state.mark.y - markHeight/2 ) })"} 
    >

      { if DEBUG
        <text fontSize="40" fill="blue">{@state.mark.key}</text>
      }
      
      <Draggable
        onStart = {@props.handleMarkClick.bind @props.mark} 
        onDrag = {markDragHandler} >
        <rect 
          className   = "mark-rectangle"
          x           = 0
          y           = 0
          viewBox     = {"0 0 @props.imageWidth @props.imageHeight"}
          width       = {Math.ceil( @props.imageWidth - 2*@state.strokeWidth ) }
          height      = {markHeight}
          fill        = {if @props.selected then "rgba(255,102,0,0.25)" else "rgba(0,0,0,0.5)"}
          stroke      = {@state.strokeColor}
          strokeWidth = {@state.strokeWidth}
        />
      </Draggable>

      { 

        if @state.markStatus is 'mark'
          <g>
            <ResizeButton 
              viewBox = {"0 0 @props.imageWidth @props.imageHeight"}
              className = "upperResize"
              handleResize = {@props.handleUpperResize} 
              transform = {"translate( #{@props.imageWidth/2}, #{ - Math.round @props.scrubberHeight/2 } )"} 
              scrubberHeight = {@props.scrubberHeight}
              scrubberWidth = {@props.scrubberWidth}
              workflow = {@props.workflow}
              isSelected = {@props.selected}
            />

            <ResizeButton 
              className = "lowerResize"
              handleResize = {@props.handleLowerResize} 
              transform = {"translate( #{@props.imageWidth/2}, #{ Math.round( markHeight - @props.scrubberHeight/2 ) } )"} 
              scrubberHeight = {@props.scrubberHeight}
              scrubberWidth = {@props.scrubberWidth}
              workflow = {@props.workflow}
              isSelected = {@props.selected}
            />

            <DeleteButton 
              transform = "translate(50, #{Math.round markHeight/2})" 
              onClick = {@props.onClickDelete.bind null, @props.key}
              workflow = {@props.workflow}
              isSelected = {@props.selected}
              buttonDisabled = {@state.mark.buttonDisabled}
            />
          </g>
      }
      <DoneCheckbox
        buttonDisabled = {@state.mark.buttonDisabled}
        markStatus = {@state.markStatus}
        onClickMarkButton = {@onClickMarkButton}
        transform = {"translate( #{@props.imageWidth-250}, #{ Math.round markHeight/2 -@props.scrubberHeight/2 } )"} 
      />
    </g>

module.exports = TextRowTool
  
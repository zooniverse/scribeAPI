# @cjsx React.DOM
# Model = require '../../data/model'
React = require 'react'
Draggable = require '../../lib/draggable'
DeleteButton = require './delete-button'
ResizeButton = require './resize-button'
DoneCheckbox = require './done-checkbox'

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
    # # DEBUG CODE
    # console.log "PROPS [#{@props.mark.yUpper},#{@props.mark.yLower}]"
    # console.log "INITIAL (STATE.X, STATE.Y): (#{Math.round @props.mark.x},#{Math.round @props.mark.y})"
    centerX: @props.mark.x
    centerY: @props.mark.y
    markHeight: @props.defaultMarkHeight
    fillColor: 'rgba(0,0,0,0.5)'
    strokeColor: 'rgba(0,0,0,0.5)'
    strokeWidth: 6
    yUpper: @props.mark.yUpper
    yLower: @props.mark.yLower
    markHeight: @props.mark.yLower - @props.mark.yUpper
    markStatus: 'mark'

  componentWillReceiveProps: ->
    @setState
      yUpper: @props.mark.yUpper
      yLower: @props.mark.yLower
      centerX: @props.mark.x
      centerY: @props.mark.y
      markHeight: @props.mark.yLower - @props.mark.yUpper

  advanceToolProgress: ->
    markStatus = @state.markStatus
    console.log 'markStatus is ', markStatus
    switch markStatus
      when 'mark'
        @setState markStatus: 'mark-finished'
        # @submitMark()
        console.log 'Mark submitted. Click TRANSCRIBE to begin transcribing.'
      when 'mark-finished'
        @setState markStatus: 'transcribe'
        # @transcribeMark(mark)
        console.log 'Going into TRANSCRIBE mode. Stand by.'
      when 'transcribe'
        @setState markStatus: 'transcribe-finished'
        # @submitTranscription()
        console.log 'Transcription submitted.'
      when 'transcribe-finished'
        console.log 'All done. Nothing left to do here.'
      else
        console.log 'WARNING: Unknown state in handleToolProgress()'

    # if @state.markStatus is 'mark'
    #   console.log 'Please mark the area...'
    # else if @state.markStatus is 'transcribe'
    #   console.log 'You may now transcribe, if you wish.'
    # else if @state.markStatus is 'complete'
    #   console.log 'All done. Nothing left to do here.'

  render: ->

    unless @state.markStatus is 'mark'
      markDragHandler = null
    else
      markDragHandler = @props.handleDragMark

    <g 
      className = "point drawing-tool" 
      transform = {"translate(#{Math.ceil @state.strokeWidth}, #{Math.round( @state.centerY - @state.markHeight/2 ) })"} 
      data-disabled = {@props.disabled || null} 
      data-selected = {@props.selected || null}
    >

      <Draggable
        onStart = {@props.handleMarkClick.bind @props.mark} 
        onDrag = {markDragHandler} >
        <rect 
          className   = "mark-rectangle"
          x           = 0
          y           = 0
          viewBox     = {"0 0 @props.imageWidth @props.imageHeight"}
          width       = {Math.ceil( @props.imageWidth - 2*@state.strokeWidth ) }
          height      = {@state.markHeight}
          fill        = {if @props.selected then "rgba(255,102,0,0.25)" else "rgba(0,0,0,0.5)"}
          stroke      = {@state.strokeColor}
          strokeWidth = {@state.strokeWidth}
        />
      </Draggable>

      { if @state.markStatus is 'mark'
          <g>
            <ResizeButton 
              viewBox     = {"0 0 @props.imageWidth @props.imageHeight"}
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
              transform = {"translate( #{@props.imageWidth/2}, #{ Math.round( @state.markHeight - @props.scrubberHeight/2 ) } )"} 
              scrubberHeight = {@props.scrubberHeight}
              scrubberWidth = {@props.scrubberWidth}
              workflow = {@props.workflow}
              isSelected = {@props.selected}
            />

            <DeleteButton 
              transform = "translate(50, #{Math.round @state.markHeight/2})" 
              onClick = {@props.onClickDelete.bind null, @props.key}
              workflow = {@props.workflow}
              isSelected = {@props.selected}
            />
          </g>
      }
      <DoneCheckbox
        markStatus = {@state.markStatus}
        advanceToolProgress = {@advanceToolProgress}
        transform = {"translate( #{@props.imageWidth-250}, #{ Math.round @state.markHeight/2 -@props.scrubberHeight/2 } )"} 
      />
    </g>

module.exports = TextRowTool
  
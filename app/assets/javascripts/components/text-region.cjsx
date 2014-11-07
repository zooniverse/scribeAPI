# @cjsx React.DOM
# Model = require '../../data/model'
React = require 'react'
Draggable = require '../lib/draggable'
DeleteButton = require './delete-button'
ResizeButton = require './resize-button'

TextRegionTool = React.createClass
  displayName: 'TextRegionTool'

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
    strokeColor: '#26baff'
    strokeWidth: 3
    yUpper: @props.mark.yUpper
    yLower: @props.mark.yLower
    markHeight: @props.mark.yLower - @props.mark.yUpper

  componentWillReceiveProps: ->
    @setState
      yUpper: @props.mark.yUpper
      yLower: @props.mark.yLower
      centerX: @props.mark.x
      centerY: @props.mark.y
      markHeight: @props.mark.yLower - @props.mark.yUpper

  render: ->

    <g 
      className = "point drawing-tool" 
      transform = {"translate(0, #{@state.centerY-@state.markHeight/2})"} 
      data-disabled = {@props.disabled || null} 
      data-selected = {@props.selected || null}
    >

      <Draggable
        onStart = {@props.handleMarkClick.bind @props.mark} 
        onDrag = {@props.handleDragMark} >
        <rect 
          className   = "mark-rectangle"
          x           = 0
          y           = 0
          viewBox     = {"0 0 @props.imageWidth @props.imageHeight"}
          width       = {@props.imageWidth}
          height      = {@state.markHeight}
          fill        = {if @props.selected then "rgba(10,10,200,0.25)" else "rgba(0,0,0,0.5)"}
          stroke      = {@state.strokeColor}
          strokeWidth = {@state.strokeWidth}
        />
      </Draggable>

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
        transform = {"translate( #{@props.imageWidth/2}, #{ Math.round(@state.markHeight) - @props.scrubberHeight/2 } )"} 
        scrubberHeight = {@props.scrubberHeight}
        scrubberWidth = {@props.scrubberWidth}
        workflow = {@props.workflow}
        isSelected = {@props.selected}

      />

      <DeleteButton 
        transform = "translate(25, #{@state.markHeight/2})" 
        onClick = {@props.onClickDelete.bind null, @props.key}
        workflow = {@props.workflow}
        isSelected = {@props.selected}
      />
    </g>

module.exports = TextRegionTool
  
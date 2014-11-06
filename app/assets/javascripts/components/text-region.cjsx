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
    console.log "PROPS [#{@props.mark.yUpper},#{@props.mark.yLower}]"
    console.log "INITIAL (STATE.X, STATE.Y): (#{Math.round @props.mark.x},#{Math.round @props.mark.y})"
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
    console.log 'TextRegion::componentWillReceiveProps()'
    @setState
      yUpper: @props.mark.yUpper
      yLower: @props.mark.yLower
      centerX: @props.mark.x
      centerY: @props.mark.y
      markHeight: @props.mark.yLower - @props.mark.yUpper

  handleMouseOver: ->
    console.log 'onMouseOver()'
    @setState 
      strokeColor: '#fff'
      fillColor: 'rgba(0,0,0,0.25)'

  handleMouseOut: ->
    console.log 'onMouseOut()'
    @setState 
      strokeColor: 'rgba(255,255,255,0.75)'
      fillColor: 'rgba(0,0,0,0.5)'

  handleDrag: (e) ->
    # return if @props.workflow isnt "text-region"
    {x,y} = @props.getEventOffset(e)

    # prevent dragging mark beyond image bounds
    return if (y-@state.markHeight/2) < 0 
    return if (y+@state.markHeight/2) > @props.imageHeight

    @setState 
      centerX: Math.round x
      centerY: Math.round y
      yUpper: Math.round( y - @state.markHeight/2 )
      yLower: Math.round( y + @state.markHeight/2 )

    # DEBUG CODE
    console.log "UPDATED MARK CENTER: #{@state.centerY}"
    console.log "[yUpper,yLower]    : [#{@state.yUpper},#{@state.yLower}]"

  # handleUpperResize: (e) ->
  #   # return if @props.workflow isnt "text-region"

  #   {x,y} = @props.getEventOffset e

  #   # prevent dragging mark beyond image bounds
  #   return if y < 0 
  #   return if y > @props.imageHeight

  #   @setState
  #     offset: Math.round( y-@state.centerY+@state.markHeight/2 )
  #     markHeight: Math.round( Math.abs( @state.markHeight - @state.offset ) )
  #     yUpper: Math.round y
  #     yLower: Math.abs( y + @state.markHeight )
    
  #   # DEBUG CODE
  #   # NOTE: yUpper and yLower are the same (refactor?)
  #   console.log 'MARK CENTER             : ', @state.centerY
  #   console.log '[yUpper,yLower]         : ', "[#{@state.yUpper},#{@state.yLower}]"
  #   console.log 'DIST. CENTER (UPPER)    : ', @state.yUpper - @state.centerY
  #   # console.log 'DIST. CENTER (LOWER)    : ', @state.yLower - @state.centerY
  #   console.log 'MARK HEIGHT             : ', @state.markHeight
  #   console.log 'OFFSET                  : ', @state.offset
  #   console.log '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< HANDLE UPPER RESIZE()'

  # handleLowerResize: (e) ->
  #   # return if @props.workflow isnt "text-region"

  #   {x,y} = @props.getEventOffset e

  #   # prevent dragging mark beyond image bounds
  #   return if y < 0 
  #   return if y > @props.imageHeight

  #   @setState
  #     offset: Math.round( y-@state.centerY-@state.markHeight/2 )
  #     markHeight: Math.round( Math.abs( @state.markHeight + @state.offset ) )
  #     yUpper: y
  #     yLower: Math.round( Math.abs( y + @state.markHeight ) )
    
  #   # DEBUG CODE
  #   # NOTE: yUpper and yLower are the same (refactor?)
  #   console.log 'MARK CENTER             : ', @state.centerY
  #   console.log '[yUpper,yLower]         : ', "[#{@state.yUpper},#{@state.yLower}]"
  #   # console.log 'DIST. CENTER (UPPER)    : ', @state.yUpper - @state.centerY
  #   console.log 'DIST. CENTER (LOWER)    : ', @state.yLower - @state.centerY
  #   console.log 'MARK HEIGHT             : ', @state.markHeight
  #   console.log 'OFFSET                  : ', @state.offset
  #   console.log '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< HANDLE LOWER RESIZE()'

  render: ->
    if @props.selected
      deleteButton = 
        <DeleteButton 
          transform = "translate(25, #{@state.markHeight/2})" 
          onClick = {@props.onClickDelete.bind null, @props.key}
          workflow = {@props.workflow}
        />
    else
      deleteButton = null

    <g 
      className = "point drawing-tool" 
      transform = {"translate(0, #{@state.centerY-@state.markHeight/2})"} 
      data-disabled = {@props.disabled || null} 
      data-selected = {@props.selected || null}
    >

      <Draggable
        onStart = {@props.select.bind null, @props.mark} 
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
        transform = {"translate( #{@props.imageWidth/2}, #{ @props.scrubberHeight/2 } )"} 
        scrubberHeight = {@props.scrubberHeight}
        scrubberWidth = {@props.scrubberWidth}
        workflow = {@props.workflow}
      />

      <ResizeButton 
        className = "lowerResize"
        handleResize = {@props.handleLowerResize} 
        transform = {"translate( #{@props.imageWidth/2}, #{ Math.round(@state.markHeight) - @props.scrubberHeight/2 } )"} 
        scrubberHeight = {@props.scrubberHeight}
        scrubberWidth = {@props.scrubberWidth}
        workflow = {@props.workflow}
      />

      {deleteButton}
    </g>

module.exports = TextRegionTool
  
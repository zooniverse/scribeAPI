# NOTE: vertical-mark-tool is basically same as tetx-row-tool without progress-button
# @cjsx React.DOM
React          = require 'react'
Draggable      = require 'lib/draggable'
DeleteButton   = require './delete-button'
ResizeButton   = require './resize-button'

DEBUG = false

module.exports = React.createClass
  displayName: 'VerticalMarkTool'

  propTypes:
    key:  React.PropTypes.number.isRequired
    mark: React.PropTypes.object.isRequired

  getInitialState: ->
    mark = @props.mark
    mark.yUpper = @props.mark.y - 50
    mark.yLower = @props.mark.y + 50
    
    # set state
    mark: mark
  
  componentWillReceiveProps: ->
    mark = @props.mark
    markHeight = mark.yLower - mark.yUpper
    mark.yUpper = mark.y - markHeight/2
    mark.yLower = mark.y + markHeight/2

    @setState mark: mark
      # , => @forceUpdate() 

  handleDrag: (e) ->
    { ex,ey } = @props.getEventOffset e
    mark = @state.mark
    markHeight = mark.yLower - mark.yUpper
    mark.x = ex + @props.clickOffset.x # add initial click offset
    mark.y = ey + @props.clickOffset.y
    mark.yUpper = mark.y - markHeight/2
    mark.yLower = mark.y + markHeight/2

    # prevent dragging mark beyond image bounds
    return if ( ey - markHeight/2 ) < 0
    return if ( ey + markHeight/2 ) > @props.imageHeight
    
    @setState mark: mark
      # , => @forceUpdate()

  handleResize: (whichOne, e) ->
    mark = @state.mark
    { ex, ey } = @props.getEventOffset e

    switch whichOne
      when 'upper'
        if mark.yLower - ey < 100 # enforce minimum height
          mark.yUpper = mark.yLower - 100
          return
        else
          dy = mark.yUpper - ey
          yUpper_p = ey
          markHeight_p = mark.yLower - mark.yUpper + dy
          y_p = yUpper_p + markHeight_p/2
          mark.yUpper = yUpper_p
          mark.markHeight = markHeight_p
          mark.y = y_p
      when 'lower'
        if ey - mark.yUpper < 100 # enforce minimum height
          mark.yLower = mark.yUpper + 100
          return
        else
          dy = ey - mark.yLower
          yLower_p = ey
          markHeight_p = mark.yLower - mark.yUpper + dy
          y_p = yLower_p - markHeight_p/2
          mark.yLower = yLower_p
          mark.markHeight = markHeight_p
          mark.y = y_p
    
    @setState mark: mark
      # , => @forceUpdate()

  render: ->
    classString = 'verticalMark drawing-tool'
    markHeight = @state.mark.yLower - @state.mark.yUpper

    strokeWidth = '6'
    strokeColor = 'rgba(0,0,0,0.5)'
    <g 
      className = {classString} 
      transform = {"translate(0, #{Math.round( @state.mark.y - markHeight/2 ) })"} 
    >
      <Draggable
        onStart = {@props.handleMarkClick.bind @props.mark} 
        onDrag = {@handleDrag} >
        <rect 
          className   = "mark-rectangle"
          x           = 0
          y           = 0
          viewBox     = {"0 0 @props.imageWidth @props.imageHeight"}
          width       = {Math.ceil( @props.imageWidth )}
          height      = {markHeight}
          fill        = {if @props.isSelected then "rgba(255,102,0,0.25)" else strokeColor}
          stroke      = {strokeColor}
          strokeWidth = {strokeWidth}
        />
      </Draggable>

      { if @props.isSelected
          scrubberWidth = 64
          scrubberHeight = 32
          <g>
            <ResizeButton 
              viewBox={"0 0 @props.imageWidth @props.imageHeight"}
              className="upperResize"
              handleResize={@handleResize.bind null, 'upper'} 
              transform={"translate( #{@props.imageWidth/2}, #{ - Math.round scrubberHeight/2 } )"} 
              scrubberHeight={scrubberHeight}
              scrubberWidth={scrubberWidth}
              isSelected={@props.isSelected}
            />

            <ResizeButton 
              className="lowerResize"
              handleResize={@handleResize.bind null, 'lower'} 
              transform={"translate( #{@props.imageWidth/2}, #{ Math.round( markHeight - scrubberHeight/2 ) } )"} 
              scrubberHeight={scrubberHeight}
              scrubberWidth={scrubberWidth}
              isSelected={@props.isSelected}
            />

            <DeleteButton 
              transform = "translate(50, #{Math.round markHeight/2})" 
              onClick = {@props.onClickDelete.bind null, @props.mark.key}
            />
          </g>
        }
    </g>
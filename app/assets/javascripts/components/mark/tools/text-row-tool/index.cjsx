# @cjsx React.DOM
React = require 'react'
Draggable = require 'lib/draggable'
DeleteButton = require './delete-button'
ResizeButton = require './resize-button'
DoneCheckbox = require './done-checkbox'

DEBUG = false

module.exports = React.createClass
  displayName: 'TextRowTool'

  propTypes:
    key:  React.PropTypes.number.isRequired
    mark: React.PropTypes.object.isRequired

  getInitialState: ->
    mark = @props.mark
    mark.yUpper = @props.mark.y - 50
    mark.yLower = @props.mark.y + 50
    mark: mark
  
  componentWillReceiveProps: ->
    @setState 
      mark: @props.mark, =>
        @forceUpdate()

  handleDrag: (e) ->
    # console.log 'mark.yUpper/yLower: ', @state.mark.yUpper, ' ', @state.mark.yLower
    # mark = @state.mark
    offset = @props.getEventOffset e
    # mark.x = offset.x
    # mark.y = offset.y
    # @setState mark: mark, =>
    #   console.log 'updated mark: ', mark.yUpper, mark.yLower

    mark = @state.mark
    mark.x = Math.round offset.x #+ @state.markOffset.x
    mark.y = Math.round offset.y #+ @state.markOffset.y
    markHeight = mark.yLower - mark.yUpper
    mark.yUpper = Math.round mark.y - markHeight/2
    mark.yLower = Math.round mark.y + markHeight/2

    # prevent dragging mark beyond image bounds
    # offset = @state.markOffset.y
    # return if ( y + offset - markHeight/2 ) < 0
    # return if ( y + offset + markHeight/2 ) > @state.imageHeight
    
    # prevent dragging mark beyond image bounds
    return if ( offset.y - markHeight/2 ) < 0
    return if ( offset.y + markHeight/2 ) > @props.imageHeight
    

    @setState mark: mark

  handleResize: (whichOne, e) ->
    mark = @state.mark
    offset = @props.getEventOffset e
    switch whichOne
      when 'upper'
        # enforce bounds
        if offset.y < 0
          offset.y = 0
          return

        if mark.yLower - offset.y < 100
          mark.yUpper = Math.round( -100 + mark.yLower )
          # @setState mark: mark
          return

        dy = mark.yUpper - offset.y
        yUpper_p = offset.y
        markHeight_p = mark.yLower - mark.yUpper + dy
        y_p = yUpper_p + markHeight_p/2
        mark.yUpper = yUpper_p
        mark.markHeight = markHeight_p
        mark.y = y_p
      when 'lower'

        # enforce bounds
        if offset.y > @state.imageHeight
          offset.y = @state.imageHeight
          return

        if offset.y - mark.yUpper < 100
          mark.yLower = Math.round( 100 + mark.yUpper )
          # @setState mark: mark
          return

        dy = offset.y - mark.yLower
        yLower_p = offset.y
        markHeight_p = mark.yLower - mark.yUpper + dy
        y_p = yLower_p - markHeight_p/2
        mark.yLower = yLower_p
        mark.markHeight = markHeight_p
        mark.y = y_p
      # else console.log 'ERROR' # TODO: probably should handle errors at some point!

    @setState mark: mark

  render: ->
    classString = 'textRow drawing-tool'
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
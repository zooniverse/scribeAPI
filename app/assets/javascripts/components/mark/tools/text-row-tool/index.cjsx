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
    mark.yUpper = @props.mark.y - 25
    mark.yLower = @props.mark.y + 25
    mark: mark
  
  componentWillReceiveProps: ->
    @setState 
      mark: @props.mark, =>
        @forceUpdate()

  handleDrag: (e) ->
    console.log 'lkxjdhklsjdh'
    @update @props.getEventOffset(e)

  handleResize: (whichOne, e) ->
    console.log 'handleUpperResize() ', whichOne

  update: ({x,y}) ->
    mark = @state.mark
    mark.x = x
    mark.y = y
    @setState mark: mark

  render: ->
    classString = 'textRow drawing-tool'
    markHeight = @state.mark.yLower - @state.mark.yUpper

    strokeWidth = '6'
    strokeColor = 'rgba(0,0,0,0.5)'
    <g 
      className = {classString} 
      transform = {"translate(#{Math.ceil strokeWidth}, #{Math.round( @state.mark.y - markHeight/2 ) })"} 
    >
      <Draggable
        onStart = {@props.handleMarkClick.bind @props.mark} 
        onDrag = {@handleDrag} >
        <rect 
          className   = "mark-rectangle"
          x           = 0
          y           = 0
          viewBox     = {"0 0 @props.imageWidth @props.imageHeight"}
          width       = {Math.ceil( @props.imageWidth - 2*strokeWidth ) }
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
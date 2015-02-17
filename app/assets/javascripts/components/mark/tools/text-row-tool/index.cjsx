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

  update: ({x,y}) ->
    mark = @state.mark
    mark.x = x
    mark.y = y
    @setState mark: mark

  render: ->
    classString = 'textRow drawing-tool'

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
        onDrag = {@handleDrag} >
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
# @cjsx React.DOM
React          = require 'react'
Draggable      = require 'lib/draggable'
Classification = require 'models/classification'
DragHandle     = require './drag-handle'
DeleteButton    = require './delete-button'

SELECTED_RADIUS = 20
DELETE_BUTTON_ANGLE = 45
DELETE_BUTTON_DISTANCE = 9 / 10
DEBUG = false


module.exports = React.createClass
  displayName: 'RectangleTool'

  propTypes:
    key:  React.PropTypes.number.isRequired
    mark: React.PropTypes.object.isRequired

  statics:
    defaultValues: ({x, y}) ->
      {x, y}

    initMove: ({x, y}) ->
      {x, y}

  getDefaultProps: ->
    width: 400
    height: 100

  getInitialState: ->
    console.log 'Rectangle GET STATE'
    console.log "PROPS", @props
    mark = @props.mark
    unless mark.status?
      mark.status = 'mark'
    mark: mark
    # set up the state in order to caluclate the polyline as rectangle
    x: @props.mark.x
    y: @props.mark.y
    width: @props.width
    height: @props.height

    buttonDisabled: false
    lockTool: false
  
  componentWillReceiveProps: ->
    @setState x: @props.mark.x
    @setState y: @props.mark.y
    @setState width: @props.width
    @setState height: @props.height

  

  handleMainDrag: (e) ->
    console.log "handleDrag (HD)"
    return if @state.lockTool
    { ex,ey } = @props.getEventOffset e
    mark = @state.mark
    markHeight = mark.yLower - mark.yUpper
    # why? in handleMarkClick clickOffset.x is mark.x - ex. Is not the same event?
    # does @props.clickOffset.x represent the mark station before the current drag event?
    mark.x = ex + @props.clickOffset.x # add initial click offset
    mark.y = ey + @props.clickOffset.y
    
    # prevent dragging mark beyond image bounds
    return if ( ey - markHeight/2 ) < 0
    return if ( ey + markHeight/2 ) > @props.imageHeight
    
    @setState x: mark.x
    @setState y: mark.y
    @setState mark: mark
      # , => @forceUpdate()

  handleMainDrag: (e, d) ->
    @props.mark.x += d.x / @props.xScale
    @props.mark.y += d.y / @props.yScale
    @props.onChange e

  handleTopLeftDrag: (e, d) ->
    console.log "HTLD", e, d
    console.log "HTLD @props", @props
    @props.mark.x += d.x / @props.xScale
    @props.mark.y += d.y / @props.yScale
    @props.width -= d.x / @props.xScale
    console.log "new width", @props.mark.width
    @props.height -= d.y / @props.yScale
    @props.onChange e
    @setState x: @props.mark.x
    @setState y: @props.mark.y
    @setState width: @props.width
    @setState height: @props.height

  getDeleteButtonPosition: ->
    theta = (DELETE_BUTTON_ANGLE) * (Math.PI / 180)
    x: (SELECTED_RADIUS / @props.xScale) * Math.cos theta
    y: -1 * (SELECTED_RADIUS / @props.yScale) * Math.sin theta

  handleMouseDown: ->
    console.log 'handleMouseDown()'
    @props.onSelect @props.mark

  render: ->
    console.log "Render: Rectangle STATE @ Render", @state
    classString = "rectangleTool"
    x1 = @state.x
    width = @state.width
    x2 = x1 + width
    y1 = @state.y
    height = @state.height
    y2 = y1 + height

    points = [
      [x1, y1].join ','
      [x2, y1].join ','
      [x2, y2].join ','
      [x1, y2].join ','
      [x1, y1].join ','
    ].join '\n'

    console.log "render props.clickOffset", @props.clickOffset
    console.log "render props", @props
    <g 
      tool={this} 
      onMouseDown={@handleMouseDown}
    >
      <g className = {classString} 
      onMouseDown={@props.onSelect unless @props.disabled}>

        <Draggable 
          onStart = {@props.handleMarkClick} 
          onDrag = {@handleMainDrag} >
          <polyline points={points} strokeWidth="5" stroke="orange" fill="none"/>
        </Draggable>

        { if @props.selected
          <g>
            <DeleteButton tool={this} x={@state.x + (width * DELETE_BUTTON_DISTANCE)} y={@state.y} />
            <DragHandle x={@props.mark.x} y={@props.mark.y}
            onDrag={@handleTopLeftDrag}
            />
          </g>
        }
      </g>
    </g>








 
    


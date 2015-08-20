React         = require 'react'
Draggable     = require 'lib/draggable'
DoneButton    = require './buttons/done-button'

module.exports = React.createClass
  displayName: 'DraggableModal'

  getDefaultProps: ->
    classes: ''
    doneButtonLabel: 'Okay'

  componentDidMount: ->
    # Prevent dragging from (presumably) accidentally selecting modal text on-drag
    $(React.findDOMNode(@)).disableSelection()

  render: ->
    onDone = @props.onDone
    if ! onDone?
      onDone = =>
        @setState closed: true

    # Position roughly in center of screen unless explicit x,y given:
    width = @props.width ? 400
    x = @props.x ? (( $(window).width() - width ) / 2 )
    y = @props.y ? (( $(window).height() - 300) / 2 ) + $(window).scrollTop()
    y = Math.max y, 100
    x = Math.max x, 100
    console.log @props.completedSteps
    console.log @props.progressSteps.length
    console.log (@props.completedSteps/@props.progressSteps.length) * 100
    progressStyle = { width: "#{(@props.completedSteps/@props.progressSteps.length) * 100}%" }
    
    <Draggable x={x} y={y}>

      <div className="draggable-modal #{@props.classes}">
        { if @props.header?
          <div className="modal-header">
            { @props.header }
          </div>
        }

        <div className="modal-body">
          { @props.children }
        </div>

        <div className="modal-buttons">
          { if @props.buttons?
              @props.buttons

            else if onDone?
              <DoneButton label={@props.doneButtonLabel} onClick={onDone} />
          }
        </div>
        {
          if @props.progressSteps
            <div className={"simple-progress-bar"}>
              <span className="tutorial-progress-ind" style={progressStyle}></span>
            </div>
        }
      </div>

    </Draggable>


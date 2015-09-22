React         = require 'react'
Draggable     = require 'lib/draggable'
DoneButton    = require './buttons/done-button'

module.exports = React.createClass
  displayName: 'DraggableModal'

  getDefaultProps: ->
    classes: ''
    doneButtonLabel: 'Done'

  componentDidMount: ->
    # Prevent dragging from (presumably) accidentally selecting modal text on-drag
    $(React.findDOMNode(@)).disableSelection()

  closeModal: ->
    if @props.onClose
      @props.onClose()
    @setState closed: true

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
    x = $(window).width() - width if x > $(window).width() - width

    <Draggable x={x} y={y}>

      <div className="draggable-modal #{@props.classes}">
        { if @props.closeButton?
          <a className="modal-close-button" onClick={@closeModal}></a>
        }

        { if @props.header?
          <div className="modal-header">
            { @props.header }
          </div>
        }

        <div className="modal-body">
          { @props.children }
        </div>


        {
          if @props.progressSteps
            <div className="simple-progress-bar" >
              {
                for step, index in @props.progressSteps
                  if index <= @props.currentStepIndex
                    <span key={index} className="tutorial-progress-ind-active" ></span>
                  else
                    <span key={index} className="tutorial-progress-ind" ></span>
              }
            </div>
        }
        <div className="modal-buttons">
          { if @props.buttons?
              @props.buttons

            else if onDone?
              <DoneButton label={@props.doneButtonLabel} onClick={onDone} />
          }
        </div>
      </div>

    </Draggable>

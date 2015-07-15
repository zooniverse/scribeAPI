React         = require 'react'
Draggable     = require 'lib/draggable'
DoneButton    = require './buttons/done-button'

module.exports = React.createClass
  displayName: 'DraggableModal'

  render: ->
    <Draggable x={@props.x} y={@props.y} >

      <div className="draggable-modal">
        { if @props.header?
          <div className="modal-header">
            { @props.header }
          </div>
        }

        <div className="modal-body">
          { @props.children }
        </div>

        <div className="modal-buttons">
          { if @props.onDone?
            <DoneButton onClick={@props.onDone} />
          }
        </div>

      </div>

    </Draggable>


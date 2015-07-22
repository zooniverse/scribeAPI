React           = require 'react'
DraggableModal  = require 'components/draggable-modal'

module.exports = React.createClass
  displayName: 'HelpModal'

  render: ->
    <DraggableModal header={@props.help.title ? 'Help'} onDone={@props.onDone} width=600 classes="help-modal">
      <div>
        { @props.help.body.split(/\n/).map (line, i) ->
            <p key={i}>{line}</p>
        }
      </div>
    </DraggableModal>


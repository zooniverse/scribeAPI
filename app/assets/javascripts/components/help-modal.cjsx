React           = require 'react'
DraggableModal  = require 'components/draggable-modal'

module.exports = React.createClass
  displayName: 'HelpModal'

  render: ->
    return null unless @props.help?
    <DraggableModal header={@props.help.title ? 'Help'} onDone={@props.onDone} width=600 classes="help-modal">
      <div dangerouslySetInnerHTML={{__html: marked( @props.help.body ) }} />
    </DraggableModal>

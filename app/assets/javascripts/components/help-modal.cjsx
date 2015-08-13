React           = require 'react'
DraggableModal  = require 'components/draggable-modal'

module.exports = React.createClass
  displayName: 'HelpModal'

  componentDidMount: ->
    el = $(React.findDOMNode(this)).find("#accordion")
    el.accordion
      collapsible: true
      active: false
      heightStyle: "content"

  render: ->
    return null unless @props.help?
    <DraggableModal header={@props.help.title ? 'Help'} onDone={@props.onDone} width=600 classes="help-modal">
      <div dangerouslySetInnerHTML={{__html: marked( @props.help.body ) }} />
    </DraggableModal>

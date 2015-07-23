React               = require 'react'
cloneWithProps      = require 'react/lib/cloneWithProps'
HelpModal           = require '../help-modal'

module.exports = React.createClass
  displayName: 'GenericTask'

  getDefaultProps: ->
    question: ''
    help: ''
    answers: ''

  render: ->
    console.log "show help? ", @props
    <div className="workflow-task">
      <span>{@props.question}</span>
      <div className="answers">
        {React.Children.map @props.answers, (answer) ->
          cloneWithProps answer,  className: 'answer'}
      </div>
      {if @props.onShowHelp?
        <p className="help">
          <button type="button" className="pill-button" onClick={@props.onShowHelp}>
            Need some help?
          </button>
        </p>
      }
    </div>


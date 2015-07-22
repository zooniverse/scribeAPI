React               = require 'react'
cloneWithProps      = require 'react/lib/cloneWithProps'
HelpModal           = require '../help-modal'

module.exports = React.createClass
  displayName: 'GenericTask'

  getDefaultProps: ->
    question: ''
    help: ''
    answers: ''

  getInitialState: ->
    helping: false

  render: ->
    <div className="workflow-task">
      <span>{@props.question}</span>
      <div className="answers">
        {React.Children.map @props.answers, (answer) ->
          cloneWithProps answer,  className: 'answer'}
      </div>
      {if @props.help
        <p className="help">
          <button type="button" className="pill-button" onClick={@toggleHelp}>
            Need some help?
          </button>
        </p>
      }
      {if @state.helping
        <HelpModal help={@props.help} onDone={=> @setState helping: false } />
      }
    </div>

  toggleHelp: ->
    @setState helping: not @state.helping

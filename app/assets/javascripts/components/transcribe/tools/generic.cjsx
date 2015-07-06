React = require 'react'
cloneWithProps = require 'react/lib/cloneWithProps'
# alert = require '../../lib/alert'
# Markdown = require '../../components/markdown'
# Tooltip = require '../../components/tooltip'

module.exports = React.createClass
  displayName: 'GenericTool'

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
        </p>}
    </div>

  toggleHelp: ->
    @setState helping: not @state.helping

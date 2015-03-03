React = require 'react'

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
      <div className="answers">
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
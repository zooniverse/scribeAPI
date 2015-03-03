React          = require 'react'
cloneWithProps = require 'react/lib/cloneWithProps'


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
      <div className="question">
        {@props.question}
      </div>
      <div className="answers">
        {React.Children.map @props.answers, (answer) ->
          cloneWithProps answer,  className: 'answer'}
      </div>
    </div>

  toggleHelp: ->
    @setState helping: not @state.helping
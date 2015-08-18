React               = require 'react'
cloneWithProps      = require 'react/lib/cloneWithProps'
HelpModal           = require '../help-modal'
HelpButton          = require 'components/buttons/help-button'
BadSubjectButton    = require 'components/buttons/bad-subject-button'

module.exports = React.createClass
  displayName: 'GenericTask'

  getDefaultProps: ->
    question: ''
    help: ''
    answers: ''

  render: ->
    console.log "rendering with: ", @props
    <div className="workflow-task">
      <span dangerouslySetInnerHTML={{__html: marked( @props.question ) }} />
      <div className="answers">
        { React.Children.map @props.answers, (answer) =>
            cloneWithProps answer,  classes: answer.props.classes + ' answer', disabled: @props.badSubject
        }
      </div>

    </div>


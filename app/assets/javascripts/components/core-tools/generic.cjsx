React               = require 'react'
cloneWithProps      = require 'react/lib/cloneWithProps'
HelpModal           = require '../help-modal'
BadSubjectButton    = require 'components/buttons/bad-subject-button'

module.exports = React.createClass
  displayName: 'GenericTask'

  getDefaultProps: ->
    question: ''
    help: ''
    answers: ''

  render: ->
    <div className="workflow-task">
      <span>{@props.question}</span>
      <div className="answers">
        { React.Children.map @props.answers, (answer) =>
            cloneWithProps answer,  classes: answer.props.classes + ' answer', disabled: @props.badSubject
        }
      </div>
      {if @props.onShowHelp?
        <button type="button" className="pill-button" onClick={@props.onShowHelp}>
          Need some help?
        </button>
      }
      {if @props.onBadSubject?
        <BadSubjectButton active={@props.badSubject} onClick={@props.onBadSubject} />
      }
      { if @props.badSubject
        <p>You've marked this subject as BAD. Thanks for flagging the issue!</p>
      }
    </div>


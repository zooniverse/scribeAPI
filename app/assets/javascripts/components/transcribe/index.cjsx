# @cjsx React.DOM
React         = require 'react'
SubjectViewer = require '../subject-viewer'

WORKFLOW_ID = '54b82b4745626f20c9010000' # transcribe workflow

Transcribe = React.createClass # rename to Classifier
  displayName: 'Transcribe'

  getInitialState: ->
    # TODO: why is workflow an array!?!?
    workflow: @props.workflow

  render: ->
    endpoint = "/workflows/#{@state.workflow[0].id}/subjects.json?limit=5"
    <SubjectViewer endpoint=endpoint workflow={@props.workflow} />

module.exports = Transcribe
window.React = React
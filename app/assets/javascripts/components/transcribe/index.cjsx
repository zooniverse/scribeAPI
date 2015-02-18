# @cjsx React.DOM
React         = require 'react'
SubjectViewer = require '../subject-viewer'

WORKFLOW_ID = '54b82b4745626f20c9010000' # transcribe workflow

Transcribe = React.createClass # rename to Classifier
  displayName: 'Transcribe'

  getInitialState: ->
    # TODO: why is workflow an array!?!?
    console.log 'WORKFLOW: ', @props.workflow
    workflow: @props.workflow

  render: ->
    <SubjectViewer 
      endpoint=endpoint={"/workflows/#{@state.workflow.id}/subjects.json?limit=5"}  
      workflow={@props.workflow} 
      tool={null}
    />

module.exports = Transcribe
window.React = React
# @cjsx React.DOM
React         = require 'react'
SubjectViewer = require '../subject-viewer'
tools         = require './tools'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'

  propTypes:
    workflow: React.PropTypes.object.isRequired

  getInitialState: ->
    # DEBUG CODE
    console.log 'MARK WORKFLOW: ', @props.workflow
   
    workflow: @props.workflow
    firstTask: true
    currentTask: null
    currentTool: null

  componentWillMount: ->
    workflow = @state.workflow
    currentTask = workflow.tasks[ workflow.first_task ]

    if @state.firstTask?
      @setState
        currentTask: currentTask
        currentTool: currentTask.tool , =>
          console.log 'first tool is: ', @state.currentTool
      
  render: ->
    <SubjectViewer
      endpoint={"/workflows/#{@state.workflow.id}/subjects.json?limit=5"} 
      workflow={@props.workflow} 
      tool={tools[@state.currentTool]} 
    />

window.React = React
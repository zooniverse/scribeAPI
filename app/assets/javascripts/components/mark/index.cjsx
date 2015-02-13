# @cjsx React.DOM
React         = require 'react'
SubjectViewer = require '../subject-viewer'
tools         = require './tools'

Mark = React.createClass # rename to Classifier
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
    # return null if @state.currentTask is null
    # console.log 'STATE: ', @state
    # console.log 'render(): task is: ', @state.currentTask
    console.log 'render(): tool is: ', @state.currentTool
    # console.log 'TOOL OBJECT: ', tools[ @state.currentTool ]

    # return null
    <SubjectViewer
      endpoint={"/workflows/#{@state.workflow.id}/subjects.json?limit=5"} 
      workflow={@props.workflow} 
      tool={tools[@state.currentTool]} />

module.exports = Mark
window.React = React
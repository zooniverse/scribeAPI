# @cjsx React.DOM
React         = require 'react'
SubjectViewer = require '../subject-viewer'
tools         = require './tools'
GenericTask   = require '../tasks/generic-task'

module.exports = React.createClass # rename to Classifier
  displayName: 'Mark'

  propTypes:
    workflow: React.PropTypes.object.isRequired

  getInitialState: ->
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
    answers = [
      {label: 'Yeah, this is pretty cool, in fact I’m going to write a big long sentence describe just how cool I think it is.'},
      {label: 'Nah'}
    ]
    # console.log 'ANSWERS: ', answers

    console.log 'TOOLS: ', @state.currentTask.options


    tools = for tool, i in @state.currentTask.options
      tool._key ?= Math.random()
      <label key={tool._key} className="minor-button">
        <span className="drawing-tool-icon">{"ICON GOES HERE"}</span>{' '}
        <input type="radio" className="drawing-tool-input" />
        <div>{tool.label}</div>
      </label>

    console.log 'TOOLS: ', tools

    <div>
      <SubjectViewer
        endpoint={"/workflows/#{@state.workflow.id}/subjects.json?limit=5"}
        workflow={@props.workflow}
        tool={tools[@state.currentTool]}
        />
      <GenericTask question={"What is this?"} help={"HELP!"} answers={tools} />
    </div>


window.React = React

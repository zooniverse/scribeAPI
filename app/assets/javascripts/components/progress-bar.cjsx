React                   = require 'react'
BaseWorkflowMethods     = require 'lib/workflow-methods-mixin'

module.exports = React.createClass # rename to Classifier
  displayName: 'ProgressBar'

  mixins: BaseWorkflowMethods

  # getInitialState: ->

  componentDidMount: ->

  componentWillMount: ->
    


  render: ->
    <div>
      <p>This will soon be a progress bar!</p>
    </div>

window.React = React

# @cjsx React.DOM

React = require 'react'

SubjectMetadata = React.createClass
  displayName: "Metadata"

  render: ->
    <div className="metadata">
      <h3>Metadata</h3>
    </div>

module.exports = SubjectMetadata
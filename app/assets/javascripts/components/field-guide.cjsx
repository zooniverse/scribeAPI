React = require 'react'

FieldGuide = React.createClass
  displayName: "FieldGuide"
  # {
  #   "History Sheet": {
  #     image: "url"
  #     information: "string"
  #   }
  # }
  propTypes:
    documents: React.PropTypes.object.isRequired

  componentDidMount: ->
    $(React.findDOMNode(this)).accordion(collapsible: true)


  render: ->
    <div id="accordion">
      <h3>History Sheet</h3>
      <div>First content panel</div>
      <h3>Attestation</h3>
      <div>Second content panel</div>
    </div>



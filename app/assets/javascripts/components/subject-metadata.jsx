/** @jsx React.DOM */

const React = require("react");

const SubjectMetadata = React.createClass({
  displayName: "Metadata",

  render() {
    return (
      <div className="metadata">
        <h3>Metadata</h3>
      </div>
    );
  }
});

module.exports = SubjectMetadata;

/** @jsx React.DOM */

const React = require("react");

const LoadingIndicator = React.createClass({
  displayName: "LoadingIndicator",

  render() {
    return (
      <span className="loading-indicator">
        Loading
        <span>•</span>
        <span>•</span>
        <span>•</span>
      </span>
    );
  }
});

module.exports = LoadingIndicator;

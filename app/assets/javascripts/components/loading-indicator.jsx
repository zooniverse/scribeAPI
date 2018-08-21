

const React = require("react");

const LoadingIndicator = require('create-react-class')({
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

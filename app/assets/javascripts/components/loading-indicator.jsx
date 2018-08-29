

const React = require("react");
const createReactClass = require("create-react-class");

const LoadingIndicator = createReactClass({
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



import React from "react";
import createReactClass from "create-react-class";

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

export default LoadingIndicator;

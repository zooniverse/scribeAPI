import React from "react";
import createReactClass from "create-react-class";

export default createReactClass({
  displayName: "NextButton",

  getDefaultProps() {
    return { label: "Next &gt;" };
  },

  render() {
    return (
      <MajorButton
        {...Object.assign({ key: "major-button" }, this.props, {
          className: "next"
        })}
      />
    );
  }
});

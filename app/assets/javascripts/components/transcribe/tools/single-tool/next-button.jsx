
import React from "react";
import createReactClass from "create-react-class";

const NextButton = createReactClass({
  displayName: "NextButton",

  render() {
    let classes = "button next";
    if (!this.props.nextStepAvailable()) {
      classes += " disabled";
    }

    return (
      <button className={classes} onClick={this.props.nextStep}>
        Next &gt;
      </button>
    );
  }
});

export default NextButton;

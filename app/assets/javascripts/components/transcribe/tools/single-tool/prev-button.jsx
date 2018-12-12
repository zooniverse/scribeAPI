
import React from "react";

import createReactClass from "create-react-class";
const PrevButton = createReactClass({
  displayName: "PrevButton",

  render() {
    let classes = "button prev";
    if (!this.props.prevStepAvailable()) {
      classes += " disabled";
    }

    return (
      <button className={classes} onClick={this.props.prevStep}>
        &lt; Back
      </button>
    );
  }
});

export default PrevButton;

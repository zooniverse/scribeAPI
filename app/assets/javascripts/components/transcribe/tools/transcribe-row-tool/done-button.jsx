
import React from "react";

import createReactClass from "create-react-class";
const DoneButton = createReactClass({
  displayName: "DoneButton",

  render() {
    let classes = "button done";
    if (this.props.nextStepAvailable()) {
      classes = classes + " disabled";
    }
    const title = "Next Entry";

    return (
      <button className={classes} onClick={this.props.nextTextEntry}>
        {title}
      </button>
    );
  }
});

export default DoneButton;

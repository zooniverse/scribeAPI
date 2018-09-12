
import React from "react";
import createReactClass from "create-react-class";

const PrevButton = createReactClass({
  displayName: "PrevButton",

  render() {
    const classes = "button prev";
    // classes = classes + ' disabled' unless @props.prevStepAvailable()

    return (
      <button className={classes} onClick={null}>
        &lt; Back
      </button>
    );
  }
});

export default PrevButton;

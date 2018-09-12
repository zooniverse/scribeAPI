
import React from "react";
import createReactClass from "create-react-class";

const NextButton = createReactClass({
  displayName: 'NextButton',

  render() {
    const classes = 'button next';
    // classes = classes + ' disabled' unless @props.nextStepAvailable()

    return (
      <button className={classes} onClick={null}>
        Next &gt;
      </button>
    );
  }
});

export default NextButton;

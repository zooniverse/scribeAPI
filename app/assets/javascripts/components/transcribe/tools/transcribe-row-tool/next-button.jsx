
const React = require("react");

const NextButton = require('create-react-class')({
  displayName: "NextButton",

  render() {
    let classes = "button next";
    if (!this.props.nextStepAvailable()) {
      classes = classes + " disabled";
    }

    return (
      <button className={classes} onClick={this.props.nextStep}>
        Next &gt;
    </button>
    );
  }
});

module.exports = NextButton;

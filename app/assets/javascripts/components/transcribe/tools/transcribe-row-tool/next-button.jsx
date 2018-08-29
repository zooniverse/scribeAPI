
const React = require("react");

const createReactClass = require("create-react-class");
module.exports = createReactClass({
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

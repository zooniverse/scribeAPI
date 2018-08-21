/** @jsx React.DOM */
const React = require("react");

const NextButton = React.createClass({
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

module.exports = NextButton;

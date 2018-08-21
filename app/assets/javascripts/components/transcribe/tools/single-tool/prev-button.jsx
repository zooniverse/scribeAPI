/** @jsx React.DOM */
const React = require("react");

const PrevButton = React.createClass({
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

module.exports = PrevButton;

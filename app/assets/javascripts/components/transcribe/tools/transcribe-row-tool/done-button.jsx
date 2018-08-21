/** @jsx React.DOM */
const React = require("react");

const DoneButton = React.createClass({
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

module.exports = DoneButton;

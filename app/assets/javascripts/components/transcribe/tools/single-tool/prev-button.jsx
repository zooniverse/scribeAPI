
const React = require("react");

const PrevButton = require('create-react-class')({
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

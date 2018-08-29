
const React = require("react");

const createReactClass = require("create-react-class");
const PrevButton = createReactClass({
  displayName: "PrevButton",

  render() {
    let classes = "button prev";
    if (!this.props.prevStepAvailable()) {
      classes = classes + " disabled";
    }

    return (
      <button className={classes} onClick={this.props.prevStep}>
        &lt; Back
    </button>
    );
  }
});

module.exports = PrevButton;

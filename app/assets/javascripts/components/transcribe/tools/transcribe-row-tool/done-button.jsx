
const React = require("react");

const createReactClass = require("create-react-class");
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

module.exports = DoneButton;

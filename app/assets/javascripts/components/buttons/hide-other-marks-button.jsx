const React = require("react");
const createReactClass = require("create-react-class");
const SmallButton = require("./small-button.jsx");

module.exports = createReactClass({
  displayName: "HideOtherMarksButton",

  render() {
    const label = this.props.active ? "Show Other Marks" : "Hide Other Marks";

    return (
      <SmallButton
        label={label}
        onClick={this.props.onClick}
        className={`ghost toggle-button ${
          this.props.active ? "toggled" : undefined
          }`}
      />
    );
  }
});

const React = require("react");
const SmallButton = require("./small-button");

module.exports = require('create-react-class')({
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

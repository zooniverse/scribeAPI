const React = require("react");
const SmallButton = require("./small-button");

module.exports = React.createClass({
  displayName: "IllegibleSubjectButton",

  render() {
    const label = this.props.active ? "Illegible" : "Illegible?";

    return (
      <SmallButton
        key="illegible-subject-button"
        label={label}
        onClick={this.props.onClick}
        className={`ghost toggle-button ${
          this.props.active ? "toggled" : undefined
          }`}
      />
    );
  }
});

const React = require("react");

module.exports = React.createClass({
  displayName: "NextButton",

  getDefaultProps() {
    return { label: "Next &gt;" };
  },

  render() {
    return (
      <MajorButton
        {...Object.assign({ key: "major-button" }, this.props, {
          className: "next"
        })}
      />
    );
  }
});

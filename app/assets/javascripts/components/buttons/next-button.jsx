const React = require("react");

module.exports = require('create-react-class')({
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

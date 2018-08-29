const React = require("react");
const createReactClass = require("create-react-class");

module.exports = createReactClass({
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

const React = require("react");
const createReactClass = require("create-react-class");
const GenericButton = require("./generic-button.jsx");

module.exports = createReactClass({
  displayName: "DoneButton",

  getDefaultProps() {
    return { label: "Done" };
  },

  render() {
    return (
      <GenericButton label={this.props.label}
        onClick={this.props.onClick}
        major={true}
        className="done"
      />
    );
  }
});

const React = require("react");
const createReactClass = require("create-react-class");
const GenericButton = require("./generic-button.jsx");

module.exports = createReactClass({
  displayName: "SmallButton",

  getDefaultProps() {
    return { label: "Next &gt;" };
  },

  render() {
    const classes = ["small-button"];
    if (this.props.className != null) {
      classes.push(this.props.className);
    }

    return (
      <GenericButton
        {...Object.assign({}, this.props, { className: classes.join(" ") })}
      />
    );
  }
});

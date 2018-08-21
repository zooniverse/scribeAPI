const React = require("react");
const GenericButton = require("./generic-button");

module.exports = require('create-react-class')({
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

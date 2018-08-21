const React = require("react");
const SmallButton = require("./small-button");

module.exports = require('create-react-class')({
  displayName: "HelpButton",

  getDefaultProps() {
    return {
      label: "Need some help?",
      key: "help-button"
    };
  },

  render() {
    const classes = ["help-button", "ghost"];
    if (this.props.className != null) {
      classes.push(this.props.className);
    }

    return (
      <SmallButton
        {...Object.assign({}, this.props, { className: classes.join(" ") })}
      />
    );
  }
});

import React from "react";
import createReactClass from "create-react-class";
import SmallButton from "./small-button.jsx";

export default createReactClass({
  displayName: "HelpButton",

  getDefaultProps() {
    return {
      label: "Need some help?"
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

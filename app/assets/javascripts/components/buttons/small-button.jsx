import React from "react";
import createReactClass from "create-react-class";
import GenericButton from "./generic-button.jsx";

export default createReactClass({
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

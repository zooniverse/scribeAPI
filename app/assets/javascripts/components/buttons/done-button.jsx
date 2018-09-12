import React from "react";
import createReactClass from "create-react-class";
import GenericButton from "./generic-button.jsx";

export default createReactClass({
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

import React from "react";
import createReactClass from "create-react-class";
import SmallButton from "./small-button.jsx";

export default createReactClass({
  displayName: "IllegibleSubjectButton",

  render() {
    const label = this.props.active ? "Illegible" : "Illegible?";

    return (
      <SmallButton
        key="illegible-subject-button"
        label={label}
        onClick={this.props.onClick}
        className={`ghost toggle-button ${
          this.props.active ? "toggled" : undefined
          }`}
      />
    );
  }
});

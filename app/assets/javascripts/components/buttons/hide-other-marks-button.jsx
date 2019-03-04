import React from "react";
import createReactClass from "create-react-class";
import SmallButton from "./small-button.jsx";

export default createReactClass({
  displayName: "HideOtherMarksButton",

  render() {
    const label = this.props.active ? "Show Other Marks" : "Hide Other Marks";

    return (
      <SmallButton
        label={label}
        onClick={this.props.onClick}
        className={`ghost toggle-button ${
          this.props.active ? "toggled" : undefined
          }`}
      />
    );
  }
});

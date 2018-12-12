
import React from "react";
import createReactClass from "create-react-class";

const DoneButton = createReactClass({
  displayName: "DoneButton",

  render() {
    const classes = "button done";
    const title = "Next";

    return (
      <button className={classes} onClick={this.props.onClick}>
        {title}
      </button>
    );
  }
});

export default DoneButton;

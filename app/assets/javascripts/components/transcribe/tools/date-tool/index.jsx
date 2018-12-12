import React from "react";
import createReactClass from "create-react-class";
import TextTool from "../text-tool/index.jsx";

export default createReactClass({
  displayName: "DateTool",

  render() {
    return (
      <TextTool {...Object.assign({}, this.props, { inputType: "date" })} />
    );
  }
});

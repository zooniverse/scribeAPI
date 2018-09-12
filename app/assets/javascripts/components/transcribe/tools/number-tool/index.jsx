import React from "react";
import createReactClass from "create-react-class";
import TextTool from "../text-tool/index.jsx";

export default createReactClass({
  displayName: "NumberTool",

  render() {
    return (
      <TextTool {...Object.assign({}, this.props, { inputType: "number" })} />
    );
  }
});

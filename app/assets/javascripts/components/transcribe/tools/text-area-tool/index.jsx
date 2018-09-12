import React from "react";
import createReactClass from "create-react-class";
import TextTool from "../text-tool/index.jsx";

const TextAreaTool = createReactClass({
  displayName: "TextAreaTool",

  render() {
    // Everything about a textarea-tool is identical in text-tool, so let's parameterize text-tool
    return (
      <TextTool {...Object.assign({}, this.props, { inputType: "textarea" })} />
    );
  }
});

export default TextAreaTool;

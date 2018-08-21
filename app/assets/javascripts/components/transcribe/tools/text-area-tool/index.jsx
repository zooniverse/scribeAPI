const React = require("react");
const TextTool = require("../text-tool");

const TextAreaTool = require('create-react-class')({
  displayName: "TextAreaTool",

  render() {
    // Everything about a textarea-tool is identical in text-tool, so let's parameterize text-tool
    return (
      <TextTool {...Object.assign({}, this.props, { inputType: "textarea" })} />
    );
  }
});

module.exports = TextAreaTool;

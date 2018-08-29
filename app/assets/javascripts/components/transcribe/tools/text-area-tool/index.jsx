const React = require("react");
const createReactClass = require("create-react-class");
const TextTool = require("../text-tool/index.jsx");

const TextAreaTool = createReactClass({
  displayName: "TextAreaTool",

  render() {
    // Everything about a textarea-tool is identical in text-tool, so let's parameterize text-tool
    return (
      <TextTool {...Object.assign({}, this.props, { inputType: "textarea" })} />
    );
  }
});

module.exports = TextAreaTool;

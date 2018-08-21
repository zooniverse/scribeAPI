const React = require("react");
const TextTool = require("../text-tool");

module.exports = require('create-react-class')({
  displayName: "DateTool",

  render() {
    return (
      <TextTool {...Object.assign({}, this.props, { inputType: "date" })} />
    );
  }
});

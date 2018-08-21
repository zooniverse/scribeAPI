const React = require("react");
const TextTool = require("../text-tool");

module.exports = React.createClass({
  displayName: "NumberTool",

  render() {
    return (
      <TextTool {...Object.assign({}, this.props, { inputType: "number" })} />
    );
  }
});

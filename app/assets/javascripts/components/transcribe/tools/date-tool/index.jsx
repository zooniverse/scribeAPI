const React = require("react");
const TextTool = require("../text-tool");

module.exports = React.createClass({
  displayName: "DateTool",

  render() {
    return (
      <TextTool {...Object.assign({}, this.props, { inputType: "date" })} />
    );
  }
});

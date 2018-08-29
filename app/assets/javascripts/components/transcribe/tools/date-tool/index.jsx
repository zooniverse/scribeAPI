const React = require("react");
const createReactClass = require("create-react-class");
const TextTool = require("../text-tool/index.jsx");

module.exports = createReactClass({
  displayName: "DateTool",

  render() {
    return (
      <TextTool {...Object.assign({}, this.props, { inputType: "date" })} />
    );
  }
});

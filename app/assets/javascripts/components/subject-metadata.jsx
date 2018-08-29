

const React = require("react");
const createReactClass = require("create-react-class");

const SubjectMetadata = createReactClass({
  displayName: "Metadata",

  render() {
    return (
      <div className="metadata">
        <h3>Metadata</h3>
      </div>
    );
  }
});

module.exports = SubjectMetadata;

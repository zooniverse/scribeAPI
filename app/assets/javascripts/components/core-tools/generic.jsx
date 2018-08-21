const React = require("react");
const cloneWithProps = require("react/lib/cloneWithProps");

module.exports = React.createClass({
  displayName: "GenericTask",

  getDefaultProps() {
    return {
      question: "",
      help: "",
      answers: ""
    };
  },

  render() {
    return (
      <div className="workflow-task">
        <span
          dangerouslySetInnerHTML={{ __html: marked(this.props.question) }}
        />
        <div className="answers">
          {React.Children.map(this.props.answers, answer => {
            return cloneWithProps(answer, {
              classes: answer.props.classes + " answer",
              disabled: this.props.badSubject
            });
          })}
        </div>
      </div>
    );
  }
});

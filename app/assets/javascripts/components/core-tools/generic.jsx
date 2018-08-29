const React = require("react");
const createReactClass = require("create-react-class");

module.exports = createReactClass({
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
            return React.cloneElement(answer, {
              className: answer.props.className + " answer",
              disabled: this.props.badSubject
            });
          })}
        </div>
      </div>
    );
  }
});

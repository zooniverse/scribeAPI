const React = require("react");

module.exports = require('create-react-class')({
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
              classes: answer.props.classes + " answer",
              disabled: this.props.badSubject
            });
          })}
        </div>
      </div>
    );
  }
});

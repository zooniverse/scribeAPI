/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
// alert = require 'lib/alert'
// Markdown = require '../../components/markdown'
// Tooltip = require '../../components/tooltip'

const createReactClass = require("create-react-class");
module.exports = createReactClass({
  displayName: "GenericTool",

  getDefaultProps() {
    return {
      question: "",
      help: "",
      answers: ""
    };
  },

  getInitialState() {
    return { helping: false };
  },

  render() {
    return (
      <div className="workflow-task">
        <span>{this.props.question}</span>
        <div className="answers">
          {React.Children.map(this.props.answers, answer =>
            React.cloneElement(answer, { className: "answer" })
          )}
        </div>
        {this.props.help ? (
          <p className="help">
            <button type="button" className="pill-button" onClick={this.toggleHelp}>
              Need some help?
            </button>
          </p>
        ) : undefined}
      </div>
    );
  },

  toggleHelp() {
    return this.setState({ helping: !this.state.helping });
  }
});

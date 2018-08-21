/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const GenericTask = require("./generic");
// Markdown = require '../../components/markdown'

const NOOP = Function.prototype;

// Summary = React.createClass
//   displayName: 'SingleChoiceSummary'

//   getDefaultProps: ->
//     task: null
//     annotation: null
//     expanded: false

//   getInitialState: ->
//     expanded: @props.expanded

//   render: ->
//     <div className="classification-task-summary">
//       <div className="question">
//         {@props.task.question}
//         {if @state.expanded
//           <button type="button" className="toggle-more" onClick={@setState.bind this, expanded: false, null}>Less</button>
//         else
//           <button type="button" className="toggle-more" onClick={@setState.bind this, expanded: true, null}>More</button>}
//       </div>
//       <div className="answers">
//         {if @state.expanded
//           for answer, i in @props.task.answers
//             answer._key ?= Math.random()
//             <div key={answer._key} className="answer">
//               {if i is @props.annotation.value
//                 <i className="fa fa-check-circle-o fa-fw"></i>
//               else
//                 <i className="fa fa-circle-o fa-fw"></i>}
//               {@props.task.answers[i].label}
//             </div>
//         else if @props.annotation.value?
//           <div className="answer">
//             <i className="fa fa-check-circle-o fa-fw"></i>
//             {@props.task.answers[@props.annotation.value].label}
//           </div>
//         else
//           <div className="answer">No answer</div>}
//       </div>
//     </div>

module.exports = React.createClass({
  displayName: "SingleChoiceTask",

  statics: {
    // Summary: Summary # don't use Summary (yet?)

    getDefaultAnnotation() {
      return { value: null };
    }
  },

  getDefaultProps() {
    return {
      task: null,
      annotation: null,
      onChange: NOOP
    };
  },

  render() {
    let k;
    const answers = (
      <select
        className="pick-one-dropdown"
        name="select"
        required="true"
        onChange={this.handleChange.bind(this, k)}
      >
        <option value="">Please select one</option>
        {(() => {
          const result = [];
          for (k in this.props.task.tool_config.options) {
            const answer = this.props.task.tool_config.options[k];
            result.push(<option value={k}>{answer.label}</option>);
          }

          return result;
        })()}
      </select>
    );

    return (
      <GenericTask
        ref="inputs"
        question={this.props.task.instruction}
        help={this.props.task.help}
        answers={answers}
      />
    );
  },

  handleChange(index, e) {
    const { value } = $(this.refs.inputs.getDOMNode()).find("select")[0];
    this.props.onChange({
      value
    });
    return this.forceUpdate();
  }
}); // update the radiobuttons after selection

window.React = React;

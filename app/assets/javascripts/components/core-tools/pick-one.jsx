/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const createReactClass = require("create-react-class");
const PropTypes = require('prop-types');
const GenericTask = require("./generic.jsx");
const LabeledRadioButton = require("../buttons/labeled-radio-button.jsx");

// Markdown = require '../../components/markdown'

const NOOP = Function.prototype;

// Summary = createReactClass
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

module.exports = createReactClass({
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

  propTypes() {
    return {
      task: PropTypes.object.isRequired,
      annotation: PropTypes.object.isRequired,
      onChange: PropTypes.func.isRequired
    };
  },

  render() {
    const answers = (() => {
      const result = [];
      for (let answer of Array.from(this.props.task.tool_config.options)) {
        if (answer._key == null) {
          answer._key = Math.random();
        }
        const checked = answer.value === this.props.annotation.value;
        const classes = ["minor-button"];
        if (checked) {
          classes.push("active");
        }

        result.push(
          <LabeledRadioButton
            key={answer._key}
            classes={classes.join(" ")}
            value={answer.value}
            checked={checked}
            onChange={this.handleChange.bind(this, answer.value)}
            label={answer.label}
          />
        );
      }
      return result;
    })();

    return (
      <GenericTask
        {...Object.assign({ ref: "inputs" }, this.props, {
          question: this.props.task.instruction,
          answers: answers
        })}
      />
    );
  },

  handleChange(index, e) {
    if (e.target.checked) {
      this.props.onChange({
        value: e.target.value
      });
      return this.forceUpdate();
    }
  }
}); // update the radiobuttons after selection

window.React = React;

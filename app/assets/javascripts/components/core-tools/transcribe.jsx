/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react";
import createReactClass from "create-react-class";
import GenericTask from "./generic.jsx";
// Markdown = require '../../components/markdown'

const NOOP = Function.prototype;

const icons = {
  point: (
    <svg viewBox="0 0 100 100">
      <circle className="shape" r="30" cx="50" cy="50" />
      <line className="shape" x1="50" y1="5" x2="50" y2="40" />
      <line className="shape" x1="95" y1="50" x2="60" y2="50" />
      <line className="shape" x1="50" y1="95" x2="50" y2="60" />
      <line className="shape" x1="5" y1="50" x2="40" y2="50" />
    </svg>
  ),

  line: (
    <svg viewBox="0 0 100 100">
      <line className="shape" x1="25" y1="90" x2="75" y2="10" />
    </svg>
  ),

  rectangle: (
    <svg viewBox="0 0 100 100">
      <rect className="shape" x="10" y="30" width="80" height="40" />
    </svg>
  ),

  polygon: (
    <svg viewBox="0 0 100 100">
      <polyline className="shape" points="50, 5 90, 90 50, 70 5, 90 50, 5" />
    </svg>
  ),

  circle: (
    <svg viewBox="0 0 100 100">
      <ellipse className="shape" rx="33" ry="33" cx="50" cy="50" />
    </svg>
  ),

  ellipse: (
    <svg viewBox="0 0 100 100">
      <ellipse
        className="shape"
        rx="45"
        ry="25"
        cx="50"
        cy="50"
        transform="rotate(-30, 50, 50)"
      />
    </svg>
  )
};

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
//         {@props.task.instruction}
//         {if @state.expanded
//           <button type="button" className="toggle-more" onClick={@setState.bind this, expanded: false, null}>Less</button>
//         else
//           <button type="button" className="toggle-more" onClick={@setState.bind this, expanded: true, null}>More</button>}
//         {if @props.onToggle?
//           if @props.inactive
//             <button type="button"><i className="fa fa-eye fa-fw"></i></button>
//           else
//             <button type="button"><i className="fa fa-eye-slash fa-fw"></i></button>}
//       </div>

//       {for tool, i in @props.task.tools
//         tool._key ?= Math.random()
//         toolMarks = (mark for mark in @props.annotation.value when mark.tool is i)
//         if @state.expanded or toolMarks.length isnt 0
//           <div key={tool._key} className="answer">
//             {tool.type} <strong>{tool.label}</strong> ({[].concat toolMarks.length})
//             {if @state.expanded
//               for mark, i in toolMarks
//                 mark._key ?= Math.random()
//                 <div key={mark._key}>
//                   {i + 1}){' '}
//                   {for key, value of mark when key not in ['tool', 'sources'] and key.charAt(0) isnt '_'
//                     <code key={key}><strong>{key}</strong>: {JSON.stringify value}&emsp;</code>}
//                 </div>}
//           </div>}
//     </div>

export default createReactClass({
  displayName: "TranscribeTask",

  statics: {
    // Summary: Summary

    getDefaultAnnotation() {
      return {
        _toolIndex: 0,
        value: []
      };
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
    const tools = (() => {
      const result = [];
      for (var i = 0; i < this.props.task.tools.length; i++) {
        const tool = this.props.task.tools[i];
        if (tool._key == null) {
          tool._key = Math.random();
        }

        const count = Array.from(this.props.annotation.value)
          .filter(mark => mark.tool === i)
          .map(mark => true).length;

        result.push(
          <label
            key={tool._key}
            className={`minor-button ${
              i ===
                (this.props.annotation._toolIndex != null
                  ? this.props.annotation._toolIndex
                  : 0)
                ? "active"
                : ""
              }`}
          >
            <span className="drawing-tool-icon" style={{ color: tool.color }}>
              {icons[tool.type]}
            </span>{" "}
            <input
              type="radio"
              className="drawing-tool-input"
              checked={
                i ===
                (this.props.annotation._toolIndex != null
                  ? this.props.annotation._toolIndex
                  : 0)
              }
              onChange={this.handleChange.bind(this, i)}
            />
            <span>{tool.label}</span>
            {count !== 0 && <span className="tool-count">({count})</span>}
          </label>
        );
      }
      return result;
    })();

    return (
      <GenericTask
        question={this.props.task.instruction}
        help={this.props.task.help}
        answers={tools}
      />
    );
  },

  handleChange(index, e) {
    if (e.target.checked) {
      this.props.annotation._toolIndex = index;
      if (typeof this.props.onChange === "function") {
        this.props.onChange(e);
      }
      return this.forceUpdate();
    }
  }
});

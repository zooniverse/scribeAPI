/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const ReactDOM = require("react-dom");
const createReactClass = require("create-react-class");
const GenericTask = require("./generic.jsx");
// Markdown = require '../../components/markdown'

const NOOP = Function.prototype;

const icons = {
  pointTool: (
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

  rectangleTool: (
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

module.exports = createReactClass({
  displayName: "PickOneMarkOne",
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
    // task: null
    // annotation: null
    return { onChange: NOOP };
  },

  componentDidMount() { },
  // @setState subToolIndex: 0
  // @handleChange 0
  // @setSubToolIndex @props.annotation?.subToolIndex ? 0

  componentWillReceiveProps(new_props) { },
  // if ! new_props.annotation?.subToolIndex
  // @props.onChange? @state.annotation

  // @state.annotation
  // @handleChange 0
  componentWillUnmount() {
    this.setState({
      subToolIndex: 0,
      tool:
        this.props.task != null
          ? this.props.task.tool_config.options[0]
          : undefined
    });
    // Ensure mark/index subToolIndex is set to 0 in case next task uses a pick-one-*
    return typeof this.props.onChange === "function"
      ? this.props.onChange({ subToolIndex: 0 })
      : undefined;
  },

  getInitialState() {
    return {
      subToolIndex: 0, // @props.annotation?.subToolIndex ? 0
      tool:
        this.props.task != null
          ? this.props.task.tool_config.options[0]
          : undefined
    };
  },

  // annotation: $.extend({subToolIndex: null}, @props.annotation ? {})

  render() {
    // Calculate number of existing marks for each tool instance:
    const counts = {};
    for (let subject of Array.from(this.props.subject.child_subjects)) {
      // Append tool index to type just in case generates_subject_type is duplicated:
      const k = `${subject.type}-${subject.data.subToolIndex}`;
      if (counts[k] == null) {
        counts[k] = 0;
      }
      if (!subject.user_has_deleted) {
        counts[k] += 1;
      }
    }

    const tools = (() => {
      const result = [];
      for (let i = 0; i < this.props.task.tool_config.options.length; i++) {
        const tool = this.props.task.tool_config.options[i];
        if (tool._key == null) {
          tool._key = Math.random();
        }

        // How many prev marks? (i.e. child_subjects with same generates_subject_type)
        const count =
          counts[`${tool.generates_subject_type}-${i}`] != null
            ? counts[`${tool.generates_subject_type}-${i}`]
            : 0;
        const classes = ["answer"];
        if (i === this.getSubToolIndex()) {
          classes.push("active");
        }
        if (tool.help && tool.generates_subject_type) {
          classes.push("has-help");
        }

        result.push(
          <label
            key={tool._key}
            className={`${classes.join(" ")}`}
            style={{ borderColor: tool.color }}
          >
            <span className="drawing-tool-icon" style={{ color: tool.color }}>
              {icons[tool.type]}
            </span>{" "}
            <input
              type="radio"
              className="drawing-tool-input"
              checked={i === this.getSubToolIndex()}
              ref={`inp-${i}`}
              data-tool={tool}
              onChange={this.handleChange.bind(this, i)}
            />
            <span>
              {tool.label}
              {!!count && <span className="count">{count}</span>}
            </span>
            {tool.help && tool.generates_subject_type &&
              <span
                className="help"
                onClick={this.props.onSubjectHelp.bind(
                  null,
                  tool.generates_subject_type
                )}>
                <i className="fa fa-question" />
              </span>}
          </label>
        );
      }
      return result;
    })();

    // tools = null if tools.length == 1

    return (
      <GenericTask
        question={this.props.task.instruction}
        onBadSubject={this.props.onBadSubject}
        onShowHelp={this.props.onShowHelp}
        answers={tools}
      />
    );
  },

  getSubToolIndex() {
    return this.state.subToolIndex;
  },

  updateState(data) {
    return this.setState(data, () => {
      return typeof this.props.onChange === "function"
        ? this.props.onChange(data)
        : undefined;
    });
  },

  handleChange(index, e) {
    const inp = this.refs[`inp-${index}`];
    if (ReactDOM.findDOMNode(inp).checked) {
      return this.updateState({
        subToolIndex: index,
        tool: inp.dataset.tool
      });
    }
  }
});

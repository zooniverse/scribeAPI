const React = require("react");
const createReactClass = require("create-react-class");

module.exports = createReactClass({
  displayName: "LabeledRadioButton",

  getDefaultProps() {
    return {
      classes: "",
      name: "input0",
      value: "",
      checked: false,
      onChange: () => true,
      label: "",
      disabled: false
    };
  },

  render() {
    const classes = this.props.classes + (this.props.disabled ? " disabled" : "");
    return (
      <label key={this.props.key} className={classes}>
        <input
          type="radio"
          name={this.props.name}
          value={this.props.value}
          checked={this.props.checked}
          onChange={this.props.onChange}
          disabled={this.props.disabled ? "disabled" : undefined}
        />
        <span>{this.props.label}</span>
      </label>
    );
  }
});

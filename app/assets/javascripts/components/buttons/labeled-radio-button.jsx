import React from "react";

export default class LabeledRadioButton extends React.Component {
  static defaultProps = {
    classes: "",
    className: '',
    name: "input0",
    value: "",
    checked: false,
    onChange: () => true,
    label: "",
    disabled: false
  }

  render() {
    const classes = [this.props.className,
      this.props.classes,
      (this.props.disabled ? " disabled" : "")].join(' ');
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
};

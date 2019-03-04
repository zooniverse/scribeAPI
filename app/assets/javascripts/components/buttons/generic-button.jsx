import React from "react";
import { NavLink } from 'react-router-dom';

export default class GenericButton extends React.Component {
  static defaultProps = {
    label: "Okay",
    disabled: false,
    className: "",
    major: false,
    onClick: null,
    href: null
  };

  render() {
    const classes = this.props.className.split(/\s+/);
    classes.push(this.props.major ? "major-button" : "minor-button");
    if (this.props.disabled) {
      classes.push("disabled");
    }

    let { onClick } = this.props;

    if (this.props.to) {
      return (
        <NavLink className={classes.join(" ")}
          to={this.props.to}
          disabled={this.props.disabled ? "disabled" : undefined}>
          <span>{this.props.label}</span>
        </NavLink>
      );
    }
    else {
      if (this.props.href) {
        const c = this.props.onClick;
        onClick = () => {
          if (typeof c === "function") {
            c();
          }
          window.location.href = this.props.href;
        };
      }

      const key = this.props.href || this.props.onClick;

      return (
        <button key={key}
          className={classes.join(" ")}
          onClick={onClick}
          disabled={this.props.disabled ? "disabled" : undefined}>
          <span>{this.props.label}</span>
        </button>
      );
    }
  }
};

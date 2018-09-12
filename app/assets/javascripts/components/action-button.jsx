/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

import React from "react";
import createReactClass from "create-react-class";

const ActionButton = createReactClass({
  displayName: "ActionButton",

  handleClick(e) {
    if (this.props.onClick != null) {
      e.preventDefault(); // prevent browser's default submit action
      return this.props.onClick();
    }
  },

  render() {
    let classes;
    if (this.props.type === "back") {
      classes = "action-button-back standard-button white ";
    } else if (this.props.type === "next") {
      classes = "action-button-next standard-button white ";
    } else {
      classes = "action-button standard-button white ";
    }
    if (this.props.classes != null) {
      classes = classes + this.props.classes; // TODO: check to see if this does what it should!!!
    }
    return (
      <div className={classes}>
        {this.props.type === "back" &&
          <svg id="back-arrow" width="7px" height="10px" viewBox="0 0 7 10">
            <path fillRule="evenodd" d="M 2.97 5C 2.97 5 6.69 8.37 6.69 8.37 7.1 8.74 7.1 9.34 6.69 9.71 6.28 10.09 5.62 10.09 5.2 9.71 5.2 9.71-0 5-0 5-0 5 1.49 3.65 1.49 3.65 1.49 3.65 1.49 3.65 1.49 3.65 1.49 3.65 5.2 0.29 5.2 0.29 5.62-0.08 6.28-0.08 6.69 0.29 7.1 0.66 7.1 1.26 6.69 1.63 6.69 1.63 2.97 5 2.97 5Z" fill="rgb(105,129,143)" />
          </svg>
        }
        <a onClick={this.handleClick != null ? this.handleClick : null} href={this.props.href != null ? this.props.href : "javascript:void(0);"} disabled={this.props.disabled}>
          {this.props.text}
        </a>
        {this.props.type === "next" &&
          <svg width="7px" height="10px" viewBox="0 0 7 10">
            <path fillRule="evenodd" d="M 7 5C 7 5 1.77 9.71 1.77 9.71 1.36 10.08 0.69 10.08 0.28 9.71-0.13 9.34-0.13 8.74 0.28 8.37 0.28 8.37 4.01 5 4.01 5 4.01 5 0.28 1.63 0.28 1.63-0.13 1.26-0.13 0.66 0.28 0.29 0.69-0.09 1.36-0.09 1.77 0.29 1.77 0.29 5.51 3.65 5.51 3.65 5.51 3.65 5.51 3.65 5.51 3.65 5.51 3.65 7 5 7 5Z" fill="rgb(105,129,143)" />
          </svg>
        }
      </div>
    );
  }
});
export default ActionButton;

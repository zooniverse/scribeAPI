/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const createReactClass = require("create-react-class");

module.exports = createReactClass({
  displayName: "GenericButton",

  getDefaultProps() {
    return {
      label: "Okay",
      disabled: false,
      className: "",
      major: false,
      onClick: null,
      href: null
    };
  },

  render() {
    const classes = this.props.className.split(/\s+/);
    classes.push(this.props.major ? "major-button" : "minor-button");
    if (this.props.disabled) {
      classes.push("disabled");
    }

    let { onClick } = this.props;

    if (this.props.href) {
      const c = this.props.onClick;
      onClick = () => {
        if (typeof c === "function") {
          c();
        }
        window.location.href = this.props.href;
      };
    }

    const key = this.props.href != null ? this.props.href : this.props.onClick;

    return (
      <button key={key}
        className={classes.join(" ")}
        onClick={onClick}
        disabled={this.props.disabled ? "disabled" : undefined}>
        {this.props.label}
      </button>
    );
  }
});

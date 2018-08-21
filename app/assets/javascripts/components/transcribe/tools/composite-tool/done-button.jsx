
const React = require("react");

const DoneButton = require('create-react-class')({
  displayName: "DoneButton",

  render() {
    const classes = "button done";
    const title = "Next";

    return (
      <button className={classes} onClick={this.props.onClick}>
        {title}
      </button>
    );
  }
});

module.exports = DoneButton;

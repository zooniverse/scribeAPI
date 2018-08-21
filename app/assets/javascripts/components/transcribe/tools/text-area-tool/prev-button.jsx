
const React = require("react");

const PrevButton = require('create-react-class')({
  displayName: "PrevButton",

  render() {
    const classes = "button prev";
    // classes = classes + ' disabled' unless @props.prevStepAvailable()

    return (
      <button className={classes} onClick={null}>
        &lt; Back
    </button>
    );
  }
});

module.exports = PrevButton;

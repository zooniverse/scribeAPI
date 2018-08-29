
const React = require("react");

const createReactClass = require("create-react-class");
const PrevButton = createReactClass({
  displayName: "PrevButton",

  render() {
    const classes = "button prev";
    // classes = classes + ' disabled' #unless @props.prevStepAvailable()

    return (
      <button className={classes} onClick={null}>
        &lt; Back
    </button>
    );
  }
});

module.exports = PrevButton;

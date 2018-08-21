
const React = require("react");

const NextButton = require('create-react-class')({
  displayName: 'NextButton',

  render() {
    const classes = 'button next';
    // classes = classes + ' disabled' unless @props.nextStepAvailable()

    return (
      <button className={classes} onClick={null}>
        Next &gt;
      </button>
    );
  }
});

module.exports = NextButton;

/** @jsx React.DOM */
const React = require("react");

const NextButton = React.createClass({
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

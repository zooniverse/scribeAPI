/** @jsx React.DOM */

const React = require("react");

// React.DOM doesn't include an SVG <image> tag
// (because of its namespaced `xlink:href` attribute, I think),
// so this fakes one by wrapping it in a <g>.

module.exports = React.createClass({
  displayName: "SVGImage",

  getInitialState() {
    return { key: 0 };
  },

  getDefaultProps() {
    return {
      src: '',
      width: 0,
      height: 0
    };
  },

  render() {
    const imageHTML = `<image xlink:href='${this.props.src}' width='${
      this.props.width
      }' height='${this.props.height}' />`;
    return (
      <g
        {...Object.assign(
          {
            key: this.props.src,
            className: "svg-image-container",
            dangerouslySetInnerHTML: { __html: imageHTML }
          },
          this.props
        )}
      />
    );
  }
});

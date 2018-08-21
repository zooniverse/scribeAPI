const React = require("react");

const ZooniverseLogoSource = require('create-react-class')({
  displayName: 'ZooniverseLogoSource',

  render() {
    const symbolHTML = `\
<symbol id="zooniverse-logo-source" viewBox="0 0 100 100">
  <g fill="currentColor" stroke="transparent" stroke-width="0" transform="translate(50, 50)">
    <path d="M 0 -45 A 45 45 0 0 1 0 45 A 45 45 0 0 1 0 -45 Z M 0 -30 A 30 30 0 0 0 0 30 A 30 30 0 0 0 0 -30 Z" />
    <path d="M 0 -14 A 14 14 0 0 1 0 14 A 14 14 0 0 1 0 -14 Z" />
    <ellipse cx="0" cy="0" rx="6" ry="65" transform="rotate(50)" />
  </g>
</symbol>\
`;

    return <svg dangerouslySetInnerHTML={{ __html: symbolHTML }} />;
  }
});

const sourceContainer = document.createElement("div");
sourceContainer.id = 'zooniverse-logo-source-container'
sourceContainer.style.display = 'none'
document.body.appendChild(sourceContainer);

React.renderComponent(<ZooniverseLogoSource />, sourceContainer);

module.exports = require('create-react-class')({
  displayName: "ZooniverseLogo",

  getDefaultProps() {
    return {
      width: '1em',
      height: '1em'
    };
  },

  render() {
    const useHTML = `\
<use xlink:href="#zooniverse-logo-source" x="0" y="0" width="100" height="100" />\
`;

    return (
      <svg
        viewBox="0 0 100 100"
        width={this.props.width}
        height={this.props.height}
        className="zooniverse-logo"
        dangerouslySetInnerHTML={{ __html: useHTML }}
      />
    );
  }
});

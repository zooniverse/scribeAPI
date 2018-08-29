const ResizeButton = require("./resize-button.jsx");
const React = require("react");
const PropTypes = require('prop-types');
const createReactClass = require("create-react-class");

module.exports = createReactClass({
  displayName: 'ButtonLink',
  propTypes: {
    name: PropTypes.string,
    type: PropTypes.string,
    url: PropTypes.string
  },
  handleClick: (event) => {
    event.preventDefault();
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      type: this.props.type,
      error: (jqXHR, textStatus, errorThrown) => {
        console.log("Error in button action:", xhr, textStatus, errorThrown);
      }
    });
  },
  render: () => {
    if (this.props.type == "delete") {
      return <a type={this.props.type} url={this.props.url} onClick={this.handleClick}></a>
    } else if (this.props.type == "resize") {
      return <ResizeButton></ResizeButton>
    }
  }
});

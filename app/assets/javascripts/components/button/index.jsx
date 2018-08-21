ResizeButton = require('./resize-button');
React = require('react');

module.export = require('create-react-class')({
  displayName: 'ButtonLink',
  propTypes: {
    name: React.PropTypes.string,
    type: React.PropTypes.string,
    url: React.PropTypes.string
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

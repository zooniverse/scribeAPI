# @cjsx React.DOM

ResizeButton   = require './resize-button'

React = require 'react'

module.export = React.createClass
  displayName: 'ButtonLink'

  propTypes: 
    name: React.PropTypes.string
    type: React.PropTypes.string
    url: React.PropTypes.string

  handleClick: (event) ->
    event.preventDefault()
      $.ajax
        url: this.props.url
        dataType: 'json'
        type: this.props.type
        success: (data) ->
          #further thought needed
          #if a delete button it will depend on parent component?
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "Error in button action:", xhr, textStatus, errorThrown

  render: ->
    if @props.type == "delete"
      <a type={this.props.type} url={this.props.url} onClick={@handleClick} > </a>
    else @props.type == "resize"
      <ResizeButton></ResizeButton>



     



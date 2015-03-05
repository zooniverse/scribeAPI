# @cjsx React.DOM

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
          console.log "Success, here is data: #{data}" 
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "Error in button action:", xhr, textStatus, errorThrown


  render: ->
    <a type={this.props.type} url={this.props.url} onClick={@handleClick} > </a>



     



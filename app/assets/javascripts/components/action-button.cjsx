# @cjsx React.DOM

React = require 'react'

ActionButton = React.createClass
  displayName: "ActionButton"

  handleClick: (e) ->
    e.preventDefault() # prevent browser's default submit action
    @props.onActionSubmit()

  render: ->
    if @props.loading
      <a onClick={@handleClick} className="action-button button white disabled">LOADING...</a>
    else
      <a onClick={@handleClick} className="action-button button white ">{@props.label}</a>


module.exports = ActionButton
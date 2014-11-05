# @cjsx React.DOM

React = require 'react'

ActionButton = React.createClass
  displayName: "ActionButton"

  handleClick: (e) ->
    console.log 'ACTION'
    e.preventDefault() # prevent browser's default submit action
    @props.onActionSubmit()

  render: ->
    if @props.loading
      console.log 'LOADING...'
      <a onClick={@handleClick} className="button white action-button disabled">LOADING...</a>
    else
      <a onClick={@handleClick} className="button white action-button">{@props.label}</a>


module.exports = ActionButton
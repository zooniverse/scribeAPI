# @cjsx React.DOM
React = require 'react'

ActionButton = React.createClass
  displayName: "ActionButton"

  handleClick: (e) ->
    if @props.onClick?
      e.preventDefault() # prevent browser's default submit action
      @props.onClick()

  render: ->
    classes = "action-button standard-button white " 
    if @props.classes? then classes = classes + @props.classes # TODO: check to see if this does what it should!!!
    <a onClick={@handleClick ? null} href={@props.href ? 'javascript:void(0);'} className={classes} disabled={@props.disabled}>
      {@props.text}
    </a>

module.exports = ActionButton

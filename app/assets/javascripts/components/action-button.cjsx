# @cjsx React.DOM
React = require 'react'

ActionButton = React.createClass
  displayName: "ActionButton"

  handleClick: (e) ->
    e.preventDefault() # prevent browser's default submit action
    @props.onClick()

  render: ->
    classes = "action-button button white " 
    if @props.classes? then classes = classes + @props.classes # TODO: check to see if this does what it should!!!
    <a onClick={@handleClick} className={classes}>
      {@props.text}
    </a>

module.exports = ActionButton
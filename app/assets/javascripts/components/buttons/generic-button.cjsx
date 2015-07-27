React = require 'react'

module.exports = React.createClass
  displayName: 'GenericButton'

  getDefaultProps: ->
    label: 'Okay'
    disabled: false
    className: ''
    major: false

  render: ->
    classes = @props.className.split /\s+/
    classes.push (if @props.major then "major-button" else "minor-button")
    classes.push "disabled" if @props.disabled

    onClick = @props.onClick

    if @props.href
      c = @props.onClick
      onClick = () =>
        c?()
        window.location.href = @props.href
      
    <button className={classes.join " "} onClick={onClick} disabled={if @props.disabled then 'disabled'}>
      { @props.label }
    </button>

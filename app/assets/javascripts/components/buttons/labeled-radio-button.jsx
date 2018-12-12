React         = require 'react'

module.exports = React.createClass
  displayName: 'LabeledRadioButton'

  getDefaultProps: ->
    classes:          ''
    key:              Math.random()
    name:             'input0'
    value:            ''
    checked:          false
    onChange:         () => true
    label:            ""
    disabled:         false

  render: ->
    classes = @props.classes + (if @props.disabled then ' disabled' else '')
    <label key={@props.key} className={classes}>
      <input type="radio" name={@props.name} value={@props.value} checked={@props.checked} onChange={@props.onChange} disabled={if @props.disabled then 'disabled' } />
      <span>{@props.label}</span>
    </label>

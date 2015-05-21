DoneButton = require './done-button'

TextField = React.createClass
  displayName: 'TextField'

  render: ->
    <span>
      <div className="left">
        <div className="input-field active">
          <label>{@props.instruction}</label>
          <input
            ref="input0"
            type="text"
            data-task_key={@props.key}
            onChange={@props.handleChange}
            value={@props.val}
          />
        </div>
      </div>
      <div className="right">
        <DoneButton onClick={@props.commitAnnotation} />
      </div>
    </span>

module.exports = TextField

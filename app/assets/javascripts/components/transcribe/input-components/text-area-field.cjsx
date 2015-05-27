DoneButton = require './done-button'

TextAreaField = React.createClass
  displayName: 'TextAreaField'

  render: ->
    <span>
      <div className="left">
        <div className="input-field active">
          <label>{@props.instruction}</label>
          <textarea
            ref="input0"
            data-task_key={@props.key}
            onChange={@props.handleChange}
            value={@props.val}
            placeholder={"This is some place-holder text."}
          />
        </div>
      </div>
      <div className="right">
        <DoneButton onClick={@props.commitAnnotation} />
      </div>
    </span>

module.exports = TextAreaField

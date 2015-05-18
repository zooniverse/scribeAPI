DoneButton = require './done-button'

TextAreaField = React.createClass
  displayName: 'TextAreaField'

  render: ->
    <div>
      <div className="left">
        <div className="input-field active">
          <label>{@props.instruction}</label>
          <textarea
            ref="input0"
            data-task_key={@props.key}
            onChange={@handleChange}
            value={@props.val}
            placeholder={"This is some place-holder text."}
          />
        </div>
      </div>
      <div className="right">
        <DoneButton onClick={@props.commitAnnotation} />
      </div>
    </div>

module.exports = TextAreaField

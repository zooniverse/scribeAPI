DoneButton = require './done-button'

TestComponent = React.createClass
  displayName: 'TestComponent'

  render: ->
    <span>
      <div className="left">
        <div className="input-field active">
          <fieldset>
            <legend>Location</legend>
            <label>Name:</label>
            <input type='text'/>
            <label>Coordinates:</label>
            <label>Lat:</label><input type='text'/>
            <label>Lon:</label><input type='text'/>
            <hr>
            <label>Date:</label><input type='text'/>
            <label>Page No.:</label><input type='text'/>
          </fieldset>
        </div>
      </div>
      <div className="right">
        <DoneButton onClick={@props.commitAnnotation} />
      </div>
    </span>

module.exports = TestComponent

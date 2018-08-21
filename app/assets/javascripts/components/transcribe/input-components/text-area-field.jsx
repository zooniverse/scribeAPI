const DoneButton = require("./done-button");

const TextAreaField = require('create-react-class')({
  displayName: "TextAreaField",

  render() {
    return (
      <span>
        <div className="left">
          <div className="input-field active">
            <label>{this.props.instruction}</label>
            <textarea
              ref="input0"
              data-task_key={this.props.key}
              onChange={this.props.handleChange}
              value={this.props.val}
              placeholder="This is some place-holder text."
            />
          </div>
        </div>
        <div className="right">
          <DoneButton onClick={this.props.commitAnnotation} />
        </div>
      </span>
    );
  }
});

module.exports = TextAreaField;

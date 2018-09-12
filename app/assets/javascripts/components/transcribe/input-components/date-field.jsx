import DoneButton from "./done-button.jsx";
import createReactClass from "create-react-class";

const DateField = createReactClass({
  displayName: "DateField",

  render() {
    return (
      <span>
        <div className="left">
          <div className="input-field active">
            <label>{this.props.instruction}</label>
            <input
              ref="input0"
              type="date"
              data-task_key={this.props.key}
              onChange={this.props.handleChange}
              value={this.props.val}
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
export default DateField;

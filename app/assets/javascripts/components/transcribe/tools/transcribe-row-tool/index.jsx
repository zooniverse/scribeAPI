/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const React = require("react");
const createReactClass = require("create-react-class");

const Draggable = require("../lib/draggable.jsx");
const PrevButton = require("./prev-button.jsx");
const NextButton = require("./next-button.jsx");
const DoneButton = require("./done-button.jsx");
const TranscribeInput = require("./transcribe-input.jsx");

const TranscribeTool = createReactClass({
  displayName: "TranscribeTool",

  componentWillReceiveProps() {
    return this.setState({
      dx: window.innerWidth / 2 - 200,
      dy:
        this.props.yScale * this.props.selectedMark.yLower +
        65 -
        this.props.scrollOffset
    });
  },

  getInitialState() {
    // convert task object to array (to use .length method)
    const tasksArray = [];
    for (let key in this.props.tasks) {
      const elem = this.props.tasks[key];
      tasksArray[key] = elem;
    }

    return {
      tasks: tasksArray,
      currentStep: 0
    };
  },
  // dx: window.innerWidth/2 - 200
  // dy: @props.yScale * @props.selectedMark.yLower + 20

  componentDidMount() { },

  nextTextEntry() {
    return this.setState(
      {
        currentStep: 0,
        dx: window.innerWidth / 2 - 200,
        dy: this.props.yScale * this.props.selectedMark.yLower + 20
      },
      () => {
        return this.props.nextTextEntry();
      }
    );
  },

  nextStep(e) {
    // record transcription
    let currentStep;
    const transcription = [];

    for (let i = 0; i < this.state.tasks.length; i++) {
      const step = this.state.tasks[i];
      transcription.push({
        field_name: `${step.field_name}`,
        value: $(`.transcribe-input:eq(${step.key})`).val()
      });
    }

    this.props.recordTranscription(transcription);

    if (this.nextStepAvailable) {
      currentStep = this.state.currentStep + 1;
    } else {
      currentStep = 0;
    }

    return this.setState({ currentStep });
  },

  prevStep() {
    if (!this.prevStepAvailable()) {
      return;
    }
    return this.setState({ currentStep: this.state.currentStep - 1 });
  },

  nextStepAvailable() {
    if (this.state.currentStep + 1 > this.state.tasks.length - 1) {
      return false;
    } else {
      return true;
    }
  },

  prevStepAvailable() {
    if (this.state.currentStep - 1 >= 0) {
      return true;
    } else {
      return false;
    }
  },

  handleInitStart(e) {
    this.setState({ preventDrag: false });
    if (e.target.nodeName === "INPUT" || e.target.nodeName === "TEXTAREA") {
      this.setState({ preventDrag: true });
    }

    return this.setState({
      xClick: e.pageX - $(".transcribe-tool").offset().left,
      yClick: e.pageY - $(".transcribe-tool").offset().top
    });
  },

  handleInitDrag(e) {
    if (this.state.preventDrag) {
      return;
    } // not too happy about this one

    const dx = e.pageX - this.state.xClick - window.scrollX;
    const dy = e.pageY - this.state.yClick - window.scrollY;

    return this.setState({
      dx,
      dy
    });
  }, //, =>

  handleInitRelease() { },

  render() {
    const { currentStep } = this.state;

    const style = {
      left: this.state.dx,
      top: this.state.dy
    };

    return (
      <div className="transcribe-tool-container">
        <Draggable
          onStart={this.handleInitStart}
          onDrag={this.handleInitDrag}
          onEnd={this.handleInitRelease}
        >
          <div className="transcribe-tool" style={style}>
            <div className="left">
              {(() => {
                const result = [];
                for (let key in this.state.tasks) {
                  // NOTE: remember tasks is Object
                  const task = this.state.tasks[key];
                  result.push(
                    <TranscribeInput
                      key={key}
                      task={task}
                      currentStep={this.state.currentStep}
                    />
                  );
                }

                return result;
              })()}
            </div>
            <div className="right">
              <PrevButton
                prevStepAvailable={this.prevStepAvailable}
                prevStep={this.prevStep}
              />
              <NextButton
                nextStepAvailable={this.nextStepAvailable}
                nextStep={this.nextStep}
              />
              <DoneButton
                nextStepAvailable={this.nextStepAvailable}
                nextTextEntry={this.nextTextEntry}
              />
            </div>
          </div>
        </Draggable>
      </div>
    );
  }
});
module.exports = TranscribeTool;

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const DraggableModal = require("../../../draggable-modal");
const GenericButton = require("../../../buttons/generic-button");
const DoneButton = require("../../../buttons/done-button");
const HelpButton = require("../../../buttons/help-button");
const BadSubjectButton = require("../../../buttons/bad-subject-button");
const SmallButton = require("../../../buttons/small-button");

const VerifyTool = React.createClass({
  displayName: "VerifyTool",

  getInitialState() {
    return {
      annotation: {
        value: ""
      }
    };
  },

  getDefaultProps() {
    return {
      annotation: {},
      task: null,
      subject: null,
      standalone: true,
      annotation_key: "value",
      focus: true,
      doneButtonLabel: "Okay",
      transcribeButtonLabel: "None of these? Enter your own"
    };
  },

  componentWillReceiveProps() {
    return this.setState({
      annotation: this.props.annotation
    });
  },

  commitAnnotation() {
    return this.props.onComplete(this.state.annotation);
  },

  handleChange(e) {
    this.state.annotation[this.props.annotation_key] = e.target.value;
    return this.forceUpdate();
  },

  handleKeyPress(e) {
    if ([13].indexOf(e.keyCode) >= 0) {
      // ENTER:
      this.commitAnnotation();
      return e.preventDefault();
    }
  },

  chooseOption(e) {
    let el = $(e.target);
    if (el.tagName !== "A") {
      el = $(el.parents("a")[0]);
    }
    const value = this.props.subject.data["values"][el.data("value_index")];

    return this.setState({ annotation: value }, () => {
      return this.commitAnnotation();
    });
  },

  // this can go into a mixin? (common across all transcribe tools)
  getPosition(data) {
    let x, y;
    const yPad = 20;
    switch (data.toolName) {
      case "rectangleTool":
        ({ x } = data);
        y = parseFloat(data.y) + parseFloat(data.height) + yPad;
        break;
      case "textRowTool":
        ({ x } = data);
        y = data.yLower + yPad;
        break;
      default:
        // default for pointTool
        ({ x } = data);
        y = data.y + yPad;
    }
    return { x, y };
  },

  render() {
    // return null unless @props.viewerSize? && @props.subject?
    // return null if ! @props.scale? || ! @props.scale.horizontal?
    let label, data;
    if (this.props.loading) {
      return null;
    } // hide verify tool while loading image

    const val =
      this.state.annotation[this.props.annotation_key] != null
        ? this.state.annotation[this.props.annotation_key]
        : "";

    label = this.props.task.instruction;
    if (!this.props.standalone) {
      label = this.props.label != null ? this.props.label : "";
    }

    const buttons = [];
    console.info(`Verifying subject id ${this.props.subject.id}`);

    if (this.props.onShowHelp != null) {
      buttons.push(
        <HelpButton onClick={this.props.onShowHelp} key="help-button" />
      );
    }

    if ((this.props.task != null
      ? this.props.task.tool_config.displays_transcribe_button
      : undefined) != null &&
      this.props.subject != null) {
      const transcribe_url = `/#/transcribe/${
        this.props.subject.parent_subject_id
        }?scrollX=${window.scrollX}&scrollY=${window.scrollY}&page=${
        this.props.subject._meta != null
          ? this.props.subject._meta.current_page
          : undefined
        }`;
      buttons.push(
        <GenericButton
          key="transcribe-button"
          label={this.props.transcribeButtonLabel}
          href={transcribe_url}
          className="ghost small-button help-button"
        />
      );
    }
    // buttons.push <DoneButton label={@props.doneButtonLabel} onClick={@commitAnnotation} />

    if (this.props.onBadSubject != null) {
      buttons.push(
        <BadSubjectButton
          key="bad-subject-button"
          label={`Bad ${this.props.project.term("mark")}`}
          className="floated-left"
          active={this.props.badSubject}
          onClick={this.props.onBadSubject}
        />
      );
      if (this.props.badSubject) {
        buttons.push(<SmallButton label="Next" key="done-button" onClick={this.commitAnnotation} />);
      }
    }

    const { x, y } = this.getPosition(this.props.subject.region);
    return (
      <DraggableModal
        header={label}
        x={x * this.props.scale.horizontal + this.props.scale.offsetX}
        y={y * this.props.scale.vertical + this.props.scale.offsetY}
        onDone={this.commitAnnotation}
        buttons={buttons}
      >
        <div className="verify-tool-choices">
          {this.props.subject.data.task_prompt != null ? (
            <span>
              Original prompt: <em>{this.props.subject.data.task_prompt}</em>
            </span>
          ) : undefined}
          <ul>
            {(() => {
              const result = [];
              for (let i = 0; i < this.props.subject.data["values"].length; i++) {
                data = this.props.subject.data["values"][i];
                result.push(
                  <li key={i}>
                    <a href="javascript:void(0);" onClick={this.chooseOption} data-value_index={i} >
                      <ul className="choice clickable">
                        {(() => {
                          const result1 = [];
                          for (let k in data) {
                            // Label should be the key in the data hash unless it's a single-value hash with key 'value':
                            const v = data[k];
                            label = k !== "value" ||
                              (() => {
                                const result2 = [];
                                for (let _k in data) {
                                  const _v = data[_k];
                                  result2.push(_k);
                                }
                                return result2;
                              })().length > 1
                              ? k
                              : "";
                            // TODO: hack to approximate a friendly label in emigrant; should pull from original label:
                            label = label.replace(/em_/, '')
                            label = label.replace(/_/g, ' ')
                            result1.push(
                              <li key={k}><span className="label">{label}</span> {v}</li>
                            );
                          }

                          return result1;
                        })()}
                      </ul>
                    </a>
                  </li>
                );
              }

              return result;
            })()}
          </ul>
        </div>
      </DraggableModal>
    );
  }
});

module.exports = VerifyTool;

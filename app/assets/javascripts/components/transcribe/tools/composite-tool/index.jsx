/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const createReactClass = require("create-react-class");
const DraggableModal = require("../../../draggable-modal.jsx");
const DoneButton = require("./done-button.jsx");
const SmallButton = require("../../../buttons/small-button.jsx");
const PrevButton = require("./prev-button.jsx");
const HelpButton = require("../../../buttons/help-button.jsx");
const BadSubjectButton = require("../../../buttons/bad-subject-button.jsx");
const IllegibleSubjectButton = require("../../../buttons/illegible-subject-button.jsx");

const CompositeTool = createReactClass({
  displayName: "CompositeTool",

  getInitialState() {
    return {
      annotation: this.props.annotation != null ? this.props.annotation : {},
      viewerSize: this.props.viewerSize,
      active_field_key: Array.from(this.props.task.tool_config.options).map(
        c => c.value
      )[0]
    };
  },

  getDefaultProps() {
    return {
      annotation: {},
      task: null,
      subject: null
    };
  },

  // this can go into a mixin? (common across all transcribe tools)
  getPosition(data) {
    let x, y;
    if (data.x == null) {
      return { x: null, y: null };
    }

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
        if (data.y != null) {
          y = data.y + yPad;
        }
    }
    if (x == null) {
      x = this.props.subject.width / 2;
    }
    if (y == null) {
      y = this.props.subject.height / 2;
    }
    return { x, y };
  },

  onViewerResize(size) {
    return this.setState({
      viewerSize: size
    });
  },

  handleChange(annotation) {
    this.setState({ annotation });

    return this.props.onChange(annotation);
  }, // forward annotation to parent

  // Fires when user hits <enter> in an input
  // If there are more inputs, move focus to next input
  // Otherwise commit annotation (which is default behavior when there's only one input
  handleCompletedField() {
    const field_keys = (() => {
      const result = [];
      for (let c in this.props.task.tool_config.options) {
        result.push(c.value);
      }
      return result;
    })();
    const next_field_key =
      field_keys[field_keys.indexOf(this.state.active_field_key) + 1];

    if (next_field_key != null) {
      return this.setState({ active_field_key: next_field_key }, () => {
        return this.forceUpdate();
      });
    } else {
      return this.commitAnnotation();
    }
  },

  // User moved focus to an input:
  handleFieldFocus(annotation_key) {
    return this.setState({ active_field_key: annotation_key });
  },

  // this can go into a mixin? (common across all transcribe tools)
  commitAnnotation() {
    // Clear current annotation so that it doesn't carry over into next task if next task uses same tool
    const ann = this.state.annotation;
    this.setState({ annotation: {} }, () => {
      return this.props.onComplete(ann);
    });

    if (this.props.transcribeMode === "page" || this.props.transcribeMode === "single"
    ) {
      if (this.props.isLastSubject && this.props.task.next_task == null) {
        return this.props.returnToMarking();
      }
    }
  },

  // this can go into a mixin? (common across all transcribe tools)
  returnToMarking() {
    this.commitAnnotation();

    // transition back to mark
    return this.context.router.transitionTo(
      "mark",
      {},
      {
        subject_set_id: this.props.subject.subject_set_id,
        selected_subject_id: this.props.subject.parent_subject_id,
        page: this.props.subjectCurrentPage
      }
    );
  },

  render() {
    const buttons = [];
    // TK: buttons.push <PrevButton onClick={=> console.log "Prev button clicked!"} />

    if (this.props.onShowHelp != null) {
      buttons.push(
        <HelpButton onClick={this.props.onShowHelp} key="help-button" />
      );
    }

    if (this.props.onBadSubject != null) {
      buttons.push(
        <BadSubjectButton
          key="bad-subject-button"
          label={`Bad ${this.props.project.term("mark")}`}
          active={this.props.badSubject}
          onClick={this.props.onBadSubject}
        />
      );
    }

    if (this.props.onIllegibleSubject != null) {
      buttons.push(
        <IllegibleSubjectButton
          active={this.props.illegibleSubject}
          onClick={this.props.onIllegibleSubject}
          key="illegible-subject-button"
        />
      );
    }

    const buttonLabel =
      this.props.task.next_task != null
        ? "Continue"
        : this.props.isLastSubject &&
          (this.props.transcribeMode === "page" ||
            this.props.transcribeMode === "single")
          ? "Return to Marking"
          : "Next Entry";

    buttons.push(
      <SmallButton
        label={buttonLabel}
        key="done-button"
        onClick={this.commitAnnotation}
      />
    );

    const { x, y } = this.getPosition(this.props.subject.region);

    return (
      <DraggableModal
        x={x * this.props.scale.horizontal + this.props.scale.offsetX}
        y={y * this.props.scale.vertical + this.props.scale.offsetY}
        buttons={buttons}
        classes="transcribe-tool composite"
      >
        <label>{this.props.task.instruction}</label>
        {(() => {
          const result = [];

          for (let index = 0;
            index < this.props.task.tool_config.options.length;
            index++
          ) {
            const sub_tool = this.props.task.tool_config.options[index];
            const ToolComponent = this.props.transcribeTools[sub_tool.tool];
            const annotation_key = sub_tool.value;
            const focus = annotation_key === this.state.active_field_key;

            result.push(
              <ToolComponent
                key={index}
                task={this.props.task}
                tool_config={sub_tool.tool_config}
                subject={this.props.subject}
                workflow={this.props.workflow}
                standalone={false}
                viewerSize={this.props.viewerSize}
                onChange={this.handleChange}
                onComplete={this.handleCompletedField}
                onInputFocus={this.handleFieldFocus}
                label={sub_tool.label != null ? sub_tool.label : ""}
                focus={focus}
                scale={this.props.scale}
                annotation_key={annotation_key}
                annotation={this.state.annotation}
              />
            );
          }

          return result;
        })()}
      </DraggableModal>
    );
  }
});

module.exports = CompositeTool;

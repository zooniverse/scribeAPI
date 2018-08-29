/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const DraggableModal = require("../../../draggable-modal.jsx");
const SmallButton = require("../../../buttons/small-button.jsx");
const HelpButton = require("../../../buttons/help-button.jsx");
const BadSubjectButton = require("../../../buttons/bad-subject-button.jsx");
const IllegibleSubjectButton = require("../../../buttons/illegible-subject-button.jsx");

const createReactClass = require("create-react-class");
const TextTool = createReactClass({
  displayName: "TextTool",

  getInitialState() {
    return {
      annotation: this.props.annotation != null ? this.props.annotation : {},
      viewerSize: this.props.viewerSize,
      autocompleting: false
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

  getDefaultProps() {
    return {
      annotation: {},
      annotation_key: null,
      task: null,
      subject: null,
      standalone: true,
      focus: true,
      inputType: "text"
    };
  },

  componentWillUnmount() {
    const tool_config = this.toolConfig();
    if (tool_config.suggest === "common") {
      const el = $(this.refs.input0.getDOMNode());
      if (el.autocomplete != null) {
        return el.autocomplete("destroy");
      }
    }
  },

  toolConfig() {
    return this.props.tool_config != null
      ? this.props.tool_config
      : this.props.task.tool_config;
  },

  // Set focus on input:
  focus() {
    const el = $(
      this.refs.input0 != null ? this.refs.input0.getDOMNode() : undefined
    );
    if (el != null && el.length) {
      return el.focus();
    }
  },

  componentWillReceiveProps(new_props) {
    // PB: Note this func is defined principally to allow a parent composite-tool
    // to set focus on a child tool via props but this consistently fails to
    // actually set focus - probably because the el.focus() call is made right
    // before an onkeyup event or something, which quietly reverses it.
    if (new_props.focus) {
      this.focus();
    }

    this.applyAutoComplete();

    // Required to ensure tool has cleared annotation even if tool doesn't unmount between tasks:
    return this.setState({
      annotation: new_props.annotation != null ? new_props.annotation : {},
      viewerSize: new_props.viewerSize
    });
  },

  shouldComponentUpdate() {
    return true;
  },

  componentDidMount() {
    this.applyAutoComplete();
    if (this.props.focus) {
      return this.focus();
    }
  },

  componentDidUpdate() {
    this.applyAutoComplete();
    if (this.props.focus) {
      return this.focus();
    }
  },

  applyAutoComplete() {
    if (this.isMounted() && this.toolConfig().suggest === "common") {
      const el = $(
        this.refs.input0 != null ? this.refs.input0.getDOMNode() : undefined
      );
      return el.autocomplete({
        open: () => this.setState({ autocompleting: true }),
        close: () =>
          setTimeout(() => this.setState({ autocompleting: false }), 1000),
        select: (e, ui) => this.updateValue(ui.item.value),
        source: (request, response) => {
          const field = `${this.props.task.key}:${this.fieldKey()}`;
          return $.ajax({
            url: `/classifications/terms/${this.props.workflow.id}/${field}`,
            dataType: "json",
            data: {
              q: request.term
            },
            success: data => {
              return response(data);
            }
          });
        },
        minLength: 3
      });
    }
  },

  // Expects size hash with:
  //   w: [viewer width]
  //   h: [viewer height]
  //   scale:
  //     horizontal: [horiz scaling of image to fit within above vals]
  //     vertical:   [vert scaling of image..]
  onViewerResize(size) {
    return this.setState({
      viewerSize: size
    });
  },

  // this can go into a mixin? (common across all transcribe tools)
  // NOTE: doesn't get called unless @props.standalone is true
  commitAnnotation() {
    const ann = this.state.annotation;
    this.props.onComplete(ann);

    if (
      this.props.transcribeMode === "page" ||
      this.props.transcribeMode === "single"
    ) {
      if (this.props.isLastSubject && this.props.task.next_task == null) {
        return this.props.returnToMarking();
      }
    }
  },

  // Get key to use in annotations hash (i.e. typically 'value', unless included in composite tool)
  fieldKey() {
    if (this.props.standalone) {
      return "value";
    } else {
      return this.props.annotation_key;
    }
  },

  getCaret() {
    let el;
    return (el = $(
      this.refs.input0 != null ? this.refs.input0.getDOMNode() : undefined
    ));
  },

  updateValue(val) {
    const newAnnotation = this.state.annotation;
    newAnnotation[this.fieldKey()] = val;

    // if composite-tool is used, this will be a callback to CompositeTool::handleChange()
    // otherwise, it'll be a callback to Transcribe::handleDataFromTool()
    return this.props.onChange(newAnnotation);
  }, // report updated annotation to parent

  handleChange(e) {
    return this.updateValue(e.target.value);
  },

  handleKeyDown(e) {
    this.handleChange(e); // updates any autocomplete values

    if (
      !this.state.autocompleting &&
      [13].indexOf(e.keyCode) >= 0 &&
      !e.shiftKey
    ) {
      // ENTER
      return this.commitAnnotation();
    } else if (e.keyCode === 13 && e.shiftKey) {
      const text_area = $("textarea");
      let the_text = text_area.val();
      the_text = the_text.concat("/n");
      return text_area.val(the_text);
    }
  },

  handleBadMark() {
    const newAnnotation = [];
    return newAnnotation["low_quality_subject"];
  },

  render() {
    let atts, label;
    if (this.props.loading) {
      return null;
    } // hide transcribe tool while loading image

    let val = this.state.annotation[this.fieldKey()];
    if (val == null) {
      val = "";
    }

    if (!this.props.standalone) {
      label = this.props.label != null ? this.props.label : "";
      if (Array.isArray(label)) {
        label = label[0];
      }
    } else {
      label = this.props.task.instruction;
    }

    const ref = this.props.ref || "input0";

    // Grab examples either from examples in top level of task or (for composite tool) inside this field's option hash:
    const examples =
      this.props.task.examples != null
        ? this.props.task.examples
        : __guard__(
            Array.from(
              (this.props.task.tool_config != null
                ? this.props.task.tool_config.options
                : undefined) != null
                ? this.props.task.tool_config != null
                  ? this.props.task.tool_config.options
                  : undefined
                : []
            ).filter(t => t.value === this.props.annotation_key)[0],
            x1 => x1.examples
          );

    // create component input field(s)
    let tool_content = (
      <div className="input-field active">
        <label dangerouslySetInnerHTML={{ __html: marked(label) }} />
        {examples ? (
          <ul className="task-examples">
            {Array.from(examples).map((ex, i) => (
              <li key={i}>{ex}</li>
            ))}
          </ul>
        ) : (
          undefined
        )}
        {
          ((atts = {
            ref,
            key: `${this.props.task.key}.${this.props.annotation_key}`,
            "data-task_key": this.props.task.key,
            onKeyDown: this.handleKeyDown,
            onChange: this.handleChange,
            onFocus: () =>
              typeof this.props.onInputFocus === "function"
                ? this.props.onInputFocus(this.props.annotation_key)
                : undefined,
            value: val,
            disabled: this.props.badSubject
          }),
          this.props.inputType === "text" ? (
            <input {...Object.assign({ type: "text", value: val }, atts)} />
          ) : this.props.inputType === "textarea" ? (
            <textarea
              {...Object.assign({ key: this.props.task.key, value: val }, atts)}
            />
          ) : this.props.inputType === "number" ? (
            // Let's not make it input[type=number] because we don't want the browser to absolutely *force* numeric; We should coerce numerics without obliging
            <input {...Object.assign({ type: "text", value: val }, atts)} />
          ) : this.props.inputType === "date" ? (
            <input {...Object.assign({ type: "date", value: val }, atts)} />
          ) : (
            console.warn(`Invalid inputType specified: ${this.props.inputType}`)
          ))
        }
      </div>
    );

    if (this.props.standalone) {
      // 'standalone' true if component handles own mouse events

      const buttons = [];

      if (this.props.onShowHelp != null) {
        buttons.push(
          <HelpButton key="help-button" onClick={this.props.onShowHelp} />
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
            key="illegal-subject-button"
            active={this.props.illegibleSubject}
            onClick={this.props.onIllegibleSubject}
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

      tool_content = (
        <DraggableModal
          x={x * this.props.scale.horizontal + this.props.scale.offsetX}
          y={y * this.props.scale.vertical + this.props.scale.offsetY}
          buttons={buttons}
          classes="transcribe-tool"
        >
          {tool_content}
        </DraggableModal>
      );
    }

    return <div>{tool_content}</div>;
  }
});

module.exports = TextTool;

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}

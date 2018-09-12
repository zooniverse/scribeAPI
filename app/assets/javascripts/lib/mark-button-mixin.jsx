/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import MarkButton from "../components/mark-button.jsx";

// store keys of pre-defined mark-button states
const MARK_STATES = [
  "waiting-for-mark",
  "mark-committed",
  "transcribe-enabled",
  "transcribe-finished"
];

export default {
  getInitialState() {
    let markStatus;
    if (this.props.isPriorMark && this.props.selected) {
      markStatus = "transcribe-enabled";
    } else {
      markStatus = "waiting-for-mark";
    }
    return {
      markStatus,
      locked: ""
    };
  },

  componentWillReceiveProps(new_props) {
    let markStatus;
    if (new_props.isPriorMark && new_props.selected) {
      markStatus = "transcribe-enabled";
    } else {
      markStatus = "waiting-for-mark";
    }
    return this.setState({
      markStatus,
      locked: ""
    });
  },

  checkLocation() {
    const pattern = new RegExp("^(#/transcribe)");
    return pattern.test(`${window.location.hash}`);
  },

  renderMarkButton() {
    if (this.checkLocation()) {
      return null;
    }
    return (
      <MarkButton
        tool={this}
        onDrag={this.onClickMarkButton}
        position={this.getMarkButtonPosition()}
        markStatus={this.state.markStatus}
        locked={this.state.locked}
      />
    );
  },

  onClickMarkButton() {
    let { markStatus } = this.state;
    if (markStatus === "transcribe-finished") {
      return;
    }

    // advance to next mark state
    const key = MARK_STATES.indexOf(markStatus) + 1;
    markStatus = MARK_STATES[key];

    return this.setState({ markStatus: MARK_STATES[key] }, () =>
      this.respondToMarkState()
    );
  },

  respondToMarkState() {
    const { markStatus } = this.state;

    switch (markStatus) {
      case "mark-committed":
        // @setState locked: true
        // console.log '''
        //   1) disable mark editing
        //   2) submit mark
        //   3) wait for post confirmation
        // '''
        this.setState({ locked: true });
        return this.props.submitMark(this.props.mark);
      // console.log 'Mark submitted. Click TRANSCRIBE to begin transcribing.'
      case "mark-finished":
        return console.log(`\
1) display transcribe icon\
`);
      // @props.onClickTranscribe(@state.mark.key)
      // @transcribeMark(mark)

      // console.log 'Going into TRANSCRIBE mode. Stand by.'
      case "transcribe-enabled":
        console.log(`\
1) transition to transcribe route with subject ID\
`);
        // @submitTranscription()
        return console.log("Transcription submitted.");
      case "transcribe-finished":
        // console.log 'TRANSCRIBING MARK WITH ID: ', @props #.mark.child_subject_id
        // console.log 'STATE: ', @state
        location.replace(
          `/#/transcribe/${this.props.subject_id}?scrollX=${
            window.scrollX
          }&scrollY=${window.scrollY}&page=${
            this.props.subjectCurrentPage
          }&mark_key=${this.props.taskKey}`
        );
        this.forceUpdate();
        // @setState locked: true
        return console.log("All done. Nothing left to do here.");
      default:
    }
  },
  // @setState locked: true
  // console.log 'WARNING: Unknown state in respondToMarkState()'

  getMarkStyle(mark, selected, is_prior_mark) {
    const atts = {
      strokeWidth: selected ? 3 : 2,
      strokeColor: mark.color ? mark.color : "#43bbfd"
    };
    return atts;
  }
};

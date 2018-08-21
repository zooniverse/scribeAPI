/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const LightBox = require("./light-box");
const SubjectZoomPan = require("components/subject-zoom-pan");
const ForumSubjectWidget = require("./forum-subject-widget");
const { Link } = require("react-router");

module.exports = React.createClass({
  displayName: "SubjectSetToolbar",

  propTypes: {
    hideOtherMarks: React.PropTypes.bool.isRequired
  },

  getInitialState() {
    return {
      subject_set: this.props.subject_set,
      zoomPanViewBox: this.props.viewBox,
      active_pane: "",
      hideMarks: true
    };
  },

  togglePane(name) {
    if (this.state.active_pane === name) {
      this.setState({ active_pane: "" });
      return this.props.onHide();
    } else {
      this.setState({ active_pane: name });
      return this.props.onExpand();
    }
  },

  render() {
    // disable LightBox if work has begun
    const disableLightBox =
      this.props.task.key !== this.props.workflow.first_task ? true : false;
    return (
      <div className="subject-set-toolbar">
        <div className="subject-set-toolbar-panes">
          <div
            className={`light-box-area multi-page pane${
              this.state.active_pane === "multi-page" ? " active" : ""
              }`}
          >
            {this.props.subject_set ? (
              <LightBox
                subject_set={this.props.subject_set}
                subject_index={this.props.subject_index}
                key={this.props.subject_set.subjects[0].id}
                isDisabled={disableLightBox}
                toggleLightboxHelp={this.props.lightboxHelp}
                onSubject={this.props.onSubject}
                subjectCurrentPage={this.props.subjectCurrentPage}
                nextPage={this.props.nextPage}
                prevPage={this.props.prevPage}
                totalSubjectPages={this.props.totalSubjectPages}
              />
            ) : undefined}
          </div>
          <div
            className={`pan-zoom-area pan-zoom pane${
              this.state.active_pane === "pan-zoom" ? " active" : ""
              }`}
          >
            <SubjectZoomPan subject={this.props.subject} onChange={this.props.onZoomChange} viewBox={this.state.zoomPanViewBox} />
          </div>


        </div>
        <div className="subject-set-toolbar-links">
          <a className={`toggle-pan-zoom${
            this.state.active_pane === "pan-zoom" ? " active" : ""
            }`}
            onClick={() => this.togglePane("pan-zoom")}>
            <div className="helper">Toggle pan and zoom tool</div>
          </a>
          <a className={`toggle-multi-page${
            this.props.subject_set.subjects.length <= 1 ? " disabled" : ""
            }${this.state.active_pane === "multi-page" ? " active" : ""}`}
            onClick={() => this.togglePane("multi-page")}>
            <div className="helper">Toggle multi-page navigation</div>
          </a>
          <a className={this.props.hideOtherMarks === true
            ? "fa fa-toggle-on fa-2x"
            : "fa fa-toggle-off fa-2x"
          } onClick={this.props.toggleHideOtherMarks}>
            <div className="helper">
              {this.props.hideOtherMarks === false
                ? "Hide Marks of Other People"
                : "Showing Only Your Marks"}
            </div>
          </a>
        </div>
      </div>
    );
  }
});

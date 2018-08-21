/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const React = require("react");
const SubjectViewer = require("./subject-viewer");
const { Router, Routes, Route, Link } = require("react-router");
const SVGImage = require("./svg-image");
const Draggable = require("lib/draggable");
const LoadingIndicator = require("./loading-indicator");
const SubjectMetadata = require("./subject-metadata");
const ActionButton = require("./action-button");
const markingTools = require("./mark/tools");
const ZoomPanListenerMethods = require("lib/zoom-pan-listener-methods");
const SubjectSetToolbar = require("./subject-set-toolbar");

module.exports = require('create-react-class')({
  displayName: "SubjectSetViewer",
  resizing: false,

  propTypes: {
    onDestroy: React.PropTypes.func.isRequired
  }, //hands @handleMarkDelete, which call wmm method: @flagSubjectAsUserDeleted

  mixins: [ZoomPanListenerMethods],

  getInitialState() {
    return {
      subject_set: this.props.subject_set,
      tool: this.props.tool,
      toolbar_expanded: false
    };
  },

  advancePrevious() {
    return this.advance(-1);
  },

  advanceNext() {
    return this.advance(1);
  },

  advance(count) {
    const new_index = this.props.subject_index + count;
    if (new_index < 0 || new_index >= this.props.subject_set.subjects.length) {
      return;
    }

    // Let's just deal in indexes rather than storing both objects and indexes in state, lest they drift out of sync
    return this.setState({ subject_index: new_index }, () => {
      return typeof this.props.onViewSubject === "function"
        ? this.props.onViewSubject(new_index)
        : undefined;
    });
  },

  specificSelection(blah, new_index) {
    // this prevents navigating away from the subject during a workflow --AMS
    if (this.props.workflow.first_task === this.props.task.key) {
      return typeof this.props.onViewSubject === "function"
        ? this.props.onViewSubject(new_index)
        : undefined;
    } else {
      return null;
    }
  },

  onToolbarExpand() {
    return this.setState({ toolbar_expanded: true });
  },

  onToolbarHide() {
    return this.setState({ toolbar_expanded: false });
  },

  render() {
    if (this.props.subject_set.subjects == null) {
      return null;
    }

    return (
      <div
        className={`subject-set-viewer${
          this.state.toolbar_expanded ? " expand" : ""
        }`}
      >
        <SubjectSetToolbar
          workflow={this.props.workflow}
          task={this.props.task}
          subject={this.props.subject_set.subjects[this.props.subject_index]}
          subject_set={this.props.subject_set}
          subject_index={this.props.subject_index}
          subjectCurrentPage={this.props.subjectCurrentPage}
          lightboxHelp={this.props.lightboxHelp}
          onSubject={this.specificSelection.bind(
            this,
            this.props.subject_index
          )}
          nextPage={this.props.nextPage}
          prevPage={this.props.prevPage}
          totalSubjectPages={this.props.totalSubjectPages}
          onZoomChange={this.handleZoomPanViewBoxChange}
          viewBox={this.state.zoomPanViewBox}
          onExpand={this.onToolbarExpand}
          onHide={this.onToolbarHide}
          hideOtherMarks={this.props.hideOtherMarks}
          toggleHideOtherMarks={this.props.toggleHideOtherMarks}
        />
        <SubjectViewer
          subject={this.props.subject_set.subjects[this.props.subject_index]}
          workflow={this.props.workflow}
          task={this.props.task}
          subjectCurrentPage={this.props.subjectCurrentPage}
          annotation={this.props.annotation}
          active={true}
          onComplete={this.props.onComplete}
          onChange={this.props.onChange}
          onDestroy={this.props.onDestroy}
          subToolIndex={this.props.subToolIndex}
          destroyCurrentClassification={this.props.destroyCurrentClassification}
          hideOtherMarks={this.props.hideOtherMarks}
          currentSubtool={this.props.currentSubtool}
          viewBox={this.state.zoomPanViewBox}
          interimMarks={this.props.interimMarks}
        />
      </div>
    );
  }
});

window.React = React;

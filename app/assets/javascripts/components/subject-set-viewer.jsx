/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

import React from "react";
import PropTypes from 'prop-types';
import createReactClass from "create-react-class";
import SubjectViewer from "./subject-viewer.jsx";
import ZoomPanListenerMethods from "../lib/zoom-pan-listener-methods.jsx";
import SubjectSetToolbar from "./subject-set-toolbar.jsx";

export default createReactClass({
  displayName: "SubjectSetViewer",
  resizing: false,

  propTypes: {
    onDestroy: PropTypes.func.isRequired
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

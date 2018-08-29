/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const createReactClass = require("create-react-class");
const PropTypes = require('prop-types');
const { NavLink } = require("react-router-dom");
const SubjectSetViewer = require("../subject-set-viewer.jsx");
const coreTools = require("../core-tools/index.jsx");
const FetchSubjectSetsMixin = require("../../lib/fetch-subject-sets-mixin.jsx");
const BaseWorkflowMethods = require("../../lib/workflow-methods-mixin.jsx");
const JSONAPIClient = require("json-api-client"); // use to manage data?
const ForumSubjectWidget = require("../forum-subject-widget.jsx");
const HelpModal = require("../help-modal.jsx");
const Tutorial = require("../tutorial.jsx");
const HelpButton = require("../buttons/help-button.jsx");
const BadSubjectButton = require("../buttons/bad-subject-button.jsx");
const HideOtherMarksButton = require("../buttons/hide-other-marks-button.jsx");
const DraggableModal = require("../draggable-modal.jsx");
const Draggable = require("../../lib/draggable.jsx");

module.exports = createReactClass({
  // rename to Classifier
  displayName: "Mark",

  propTypes: {
    onCloseTutorial: PropTypes.func.isRequired
  },

  getDefaultProps() {
    return { workflowName: "mark" };
  },
  // hideOtherMarks: false

  mixins: [FetchSubjectSetsMixin, BaseWorkflowMethods], // load subjects and set state variables: subjects, currentSubject, classification

  getInitialState() {
    return {
      taskKey: null,
      classifications: [],
      classificationIndex: 0,
      subject_set_index: 0,
      subject_index: 0,
      currentSubToolIndex: 0,
      helping: false,
      hideOtherMarks: false,
      currentSubtool: null,
      showingTutorial: this.showTutorialBasedOnUser(this.props.user),
      lightboxHelp: false,
      activeSubjectHelper: null,
      subjectCurrentPage: 1
    };
  },

  componentWillReceiveProps(new_props) {
    return this.setState({
      showingTutorial: this.showTutorialBasedOnUser(new_props.user)
    });
  },

  showTutorialBasedOnUser(user) {
    // Show tutorial by default
    let show = true;
    if ((user != null ? user.tutorial_complete : undefined) != null) {
      // If we have a user, show tutorial if they haven't completed it:
      show = !user.tutorial_complete;
    }
    return show;
  },

  componentDidMount() {
    this.getCompletionAssessmentTask();
    this.fetchSubjectSetsBasedOnProps();
    return this.fetchGroups();
  },

  componentWillMount() {
    this.setState({ taskKey: this.getActiveWorkflow().first_task });
    return this.beginClassification();
  },

  componentDidUpdate(prev_props) {
    // If visitor nav'd from, for example, /mark/[some id] to /mark, this component won't re-mount, so detect transition here:
    if (prev_props.hash !== this.props.hash) {
      return this.fetchSubjectSetsBasedOnProps();
    }
  },

  toggleHelp() {
    this.setState({ helping: !this.state.helping });
    return this.hideSubjectHelp();
  },

  toggleTutorial() {
    this.setState({ showingTutorial: !this.state.showingTutorial });
    return this.hideSubjectHelp();
  },

  toggleLightboxHelp() {
    this.setState({ lightboxHelp: !this.state.lightboxHelp });
    return this.hideSubjectHelp();
  },

  toggleHideOtherMarks() {
    return this.setState({ hideOtherMarks: !this.state.hideOtherMarks });
  },

  // User changed currently-viewed subject:
  handleViewSubject(index) {
    this.setState({ subject_index: index }, () => this.forceUpdate());
    if (this.state.badSubject) {
      return this.toggleBadSubject();
    }
  },

  // User somehow indicated current task is complete; commit current classification
  handleToolComplete(annotation) {
    this.handleDataFromTool(annotation);
    return this.createAndCommitClassification(annotation);
  },

  // Handle user selecting a pick/drawing tool:
  handleDataFromTool(d) {
    // Kind of a hack: We receive annotation data from two places:
    //  1. tool selection widget in right-col
    //  2. the actual draggable marking tools
    // We want to remember the subToolIndex so that the right-col menu highlights
    // the correct tool after committing a mark. If incoming data has subToolIndex
    // but no mark location information, we know this callback was called by the
    // right-col. So only in that case, record currentSubToolIndex, which we use
    // to initialize marks going forward
    if (d.subToolIndex != null && d.x == null && d.y == null) {
      this.setState({ currentSubToolIndex: d.subToolIndex });
      if (d.tool != null) {
        return this.setState({ currentSubtool: d.tool });
      }
    } else {
      const { classifications } = this.state;
      for (let k in d) {
        const v = d[k];
        classifications[this.state.classificationIndex].annotation[k] = v;
      }

      // PB: Saving STI's notes here in case we decide tools should fully
      //   replace annotation hash rather than selectively update by key as above:
      // not clear whether we should replace annotations, or append to it --STI
      // classifications[@state.classificationIndex].annotation = d #[k] = v for k, v of d

      return this.setState({ classifications }, () => {
        return this.forceUpdate();
      });
    }
  },

  handleMarkDelete(m) {
    return this.flagSubjectAsUserDeleted(m.subject_id);
  },

  destroyCurrentClassification() {
    const { classifications } = this.state;
    classifications.splice(this.state.classificationIndex, 1);
    this.setState({
      classifications,
      classificationIndex: classifications.length - 1
    });

    // There should always be an empty classification ready to receive data:
    return this.beginClassification();
  },

  destroyCurrentAnnotation() { },
  // TODO: implement mechanism for going backwards to previous classification, potentially deleting later classifications from stack:
  // @props.classification.annotations.pop()

  completeSubjectSet() {
    this.commitCurrentClassification();
    this.beginClassification();

    // TODO: Should maybe make this workflow-configurable?
    const show_subject_assessment = true;
    if (show_subject_assessment) {
      return this.setState({
        taskKey: "completion_assessment_task"
      });
    }
  },

  completeSubjectAssessment() {
    this.commitCurrentClassification();
    this.beginClassification();
    return this.advanceToNextSubject();
  },

  nextPage(callback_fn) {
    const new_page = this.state.subjectCurrentPage + 1;
    return this.setState({ subjectCurrentPage: new_page }, () =>
      this.fetchSubjectsForCurrentSubjectSet(new_page, null, callback_fn)
    );
  },

  prevPage(callback_fn) {
    const new_page = this.state.subjectCurrentPage - 1;
    this.setState({ subjectCurrentPage: new_page });
    return this.fetchSubjectsForCurrentSubjectSet(new_page, null, callback_fn);
  },

  showSubjectHelp(subject_type) {
    return this.setState({
      activeSubjectHelper: subject_type,
      helping: false,
      showingTutorial: false,
      lightboxHelp: false
    });
  },

  hideSubjectHelp() {
    return this.setState({
      activeSubjectHelper: null
    });
  },

  render() {
    let left1, waitingForAnswer;
    let tool;
    if (
      this.getCurrentSubjectSet() == null ||
      this.getActiveWorkflow() == null
    ) {
      return null;
    }

    const currentTask = this.getCurrentTask();
    const TaskComponent = this.getCurrentTool();
    const activeWorkflow = this.getActiveWorkflow();
    const firstTask = activeWorkflow.first_task;
    const onFirstAnnotation = this.state.taskKey === firstTask;
    const currentSubtool = this.state.currentSubtool
      ? this.state.currentSubtool
      : __guard__(
        __guard__(this.getTasks()[firstTask], x1 => x1.tool_config.tools),
        x => x[0]
      );

    // direct link to this page
    const pageURL = `${location.origin}/#/mark?subject_set_id=${
      this.getCurrentSubjectSet().id
      }&selected_subject_id=${__guard__(this.getCurrentSubject(), x2 => x2.id)}`;

    if ((currentTask != null ? currentTask.tool : undefined) === "pick_one") {
      const currentAnswer = Array.from(currentTask.tool_config.options).filter(
        a => a.value === currentAnnotation.value
      )[0];
      waitingForAnswer = !currentAnswer;
    }

    return (
      <div className="classifier">
        <div className="subject-area">
          {(() => {
            if (this.state.noMoreSubjectSets) {
              const style = { marginTop: "50px" };
              return (
                <p style={style}>
                  There is nothing left to do. Thanks for your work and please
                  check back soon!
                </p>
              );
            } else if (this.state.notice) {
              return (
                <DraggableModal
                  header={this.state.notice.header}
                  onDone={this.state.notice.onClick}
                >
                  {this.state.notice.message}
                </DraggableModal>
              );
            } else if (this.getCurrentSubjectSet() != null) {
              let left;
              return (
                <SubjectSetViewer
                  subject_set={this.getCurrentSubjectSet()}
                  subject_index={this.state.subject_index}
                  workflow={this.getActiveWorkflow()}
                  task={currentTask}
                  annotation={
                    (left = __guard__(
                      this.getCurrentClassification(),
                      x3 => x3.annotation
                    )) != null
                      ? left
                      : {}
                  }
                  onComplete={this.handleToolComplete}
                  onChange={this.handleDataFromTool}
                  onDestroy={this.handleMarkDelete}
                  onViewSubject={this.handleViewSubject}
                  subToolIndex={this.state.currentSubToolIndex}
                  nextPage={this.nextPage}
                  prevPage={this.prevPage}
                  subjectCurrentPage={this.state.subjectCurrentPage}
                  totalSubjectPages={this.state.subjects_total_pages}
                  destroyCurrentClassification={
                    this.destroyCurrentClassification
                  }
                  hideOtherMarks={this.state.hideOtherMarks}
                  toggleHideOtherMarks={this.toggleHideOtherMarks}
                  currentSubtool={currentSubtool}
                  lightboxHelp={this.toggleLightboxHelp}
                  interimMarks={this.state.interimMarks}
                />
              );
            }
          })()}
        </div>
        <div className="right-column">
          <div className={`task-area ${this.getActiveWorkflow().name}`}>
            {this.getCurrentTask() != null &&
              this.getCurrentSubject() != null ? (
                <div className="task-container">
                  <TaskComponent
                    key={this.getCurrentTask().key}
                    task={currentTask}
                    annotation={
                      (left1 = __guard__(
                        this.getCurrentClassification(),
                        x4 => x4.annotation
                      )) != null
                        ? left1
                        : {}
                    }
                    onChange={this.handleDataFromTool}
                    onSubjectHelp={this.showSubjectHelp}
                    subject={this.getCurrentSubject()}
                  />
                  <nav className="task-nav">
                    {false ? (
                      <button
                        type="button"
                        className="back minor-button"
                        disabled={onFirstAnnotation}
                        onClick={this.destroyCurrentAnnotation}
                      >
                        Back
                    </button>
                    ) : (
                        undefined
                      )}
                    {this.getNextTask() && this.state.badSubject == null ? (
                      <button
                        type="button"
                        className="continue major-button"
                        disabled={waitingForAnswer}
                        onClick={this.advanceToNextTask}
                      >
                        Next
                    </button>
                    ) : this.state.taskKey === "completion_assessment_task" ? (
                      this.getCurrentSubject() ===
                        this.getCurrentSubjectSet().subjects[
                        this.getCurrentSubjectSet().subjects.length - 1
                        ] ? (
                          <button
                            type="button"
                            className="continue major-button"
                            disabled={waitingForAnswer}
                            onClick={this.completeSubjectAssessment}
                          >
                            Next
                      </button>
                        ) : (
                          <button
                            type="button"
                            className="continue major-button"
                            disabled={waitingForAnswer}
                            onClick={this.completeSubjectAssessment}
                          >
                            Next Page
                      </button>
                        )
                    ) : (
                          <button
                            type="button"
                            className="continue major-button"
                            disabled={waitingForAnswer}
                            onClick={this.completeSubjectSet}
                          >
                            Done
                    </button>
                        )}
                  </nav>
                  <div className="help-bad-subject-holder">
                    {this.getCurrentTask().help != null ? (
                      <HelpButton
                        onClick={this.toggleHelp}
                        label=""
                        className="task-help-button"
                      />
                    ) : (
                        undefined
                      )}
                    {onFirstAnnotation ? (
                      <BadSubjectButton
                        class="bad-subject-button"
                        label={`Bad ${this.props.project.term("subject")}`}
                        active={this.state.badSubject}
                        onClick={this.toggleBadSubject}
                      />
                    ) : (
                        undefined
                      )}
                    {this.state.badSubject ? (
                      <p>
                        You've marked this {this.props.project.term("subject")} as
                      BAD. Thanks for flagging the issue!{" "}
                        <strong>Press DONE to continue.</strong>
                      </p>
                    ) : (
                        undefined
                      )}
                  </div>
                </div>
              ) : (
                undefined
              )}
            <div className="task-secondary-area">
              {this.getCurrentTask() != null ? (
                <p>
                  <a className="tutorial-link" onClick={this.toggleTutorial}>
                    View A Tutorial
                  </a>
                </p>
              ) : (
                  undefined
                )}
              {this.getCurrentTask() != null &&
                this.getActiveWorkflow() != null &&
                this.getWorkflowByName("transcribe") != null ? (
                  <p>
                    <Link
                      to={`/transcribe/${
                        this.getWorkflowByName("transcribe").id
                        }/${__guard__(this.getCurrentSubject(), x5 => x5.id)}`}
                      className="transcribe-link"
                    >
                      Transcribe this {this.props.project.term("subject")} now!
                  </Link>
                  </p>
                ) : (
                  undefined
                )}
              {this.getActiveWorkflow() != null &&
                (this.state.groups != null
                  ? this.state.groups.length
                  : undefined) > 1 ? (
                  <p>
                    <NavLink
                      to={`/groups/${this.getCurrentSubjectSet().group_id}`}
                      className="about-link"
                    >
                      About this {this.props.project.term("group")}.
                  </NavLink>
                  </p>
                ) : (
                  undefined
                )}
              <div className="forum-holder">
                <ForumSubjectWidget
                  subject={this.getCurrentSubject()}
                  subject_set={this.getCurrentSubjectSet()}
                  project={this.props.project}
                />
              </div>
              <div className="social-media-container">
                <a
                  href={`https://www.facebook.com/sharer.php?u=${encodeURIComponent(
                    pageURL
                  )}`}
                  target="_blank"
                >
                  <i className="fa fa-facebook-square" />
                </a>
                <a
                  href={`https://twitter.com/home?status=${encodeURIComponent(
                    pageURL
                  )}%0A`}
                  target="_blank"
                >
                  <i className="fa fa-twitter-square" />
                </a>
                <a
                  href={`https://plus.google.com/share?url=${encodeURIComponent(
                    pageURL
                  )}`}
                  target="_blank"
                >
                  <i className="fa fa-google-plus-square" />
                </a>
              </div>
            </div>
          </div>
        </div>
        {this.props.project.tutorial != null && this.state.showingTutorial ? (
          // Check for workflow-specific tutorial
          this.props.project.tutorial.workflows != null &&
            this.props.project.tutorial.workflows[
            __guard__(this.getActiveWorkflow(), x6 => x6.name)
            ] ? (
              <Tutorial
                tutorial={
                  this.props.project.tutorial.workflows[
                  this.getActiveWorkflow().name
                  ]
                }
                onCloseTutorial={this.props.onCloseTutorial}
              />
            ) : (
              // Otherwise just show general tutorial
              <Tutorial
                tutorial={this.props.project.tutorial}
                onCloseTutorial={this.props.onCloseTutorial}
              />
            )
        ) : (
            undefined
          )}
        {this.state.helping ? (
          <HelpModal
            help={this.getCurrentTask().help}
            onDone={() => this.setState({ helping: false })}
          />
        ) : (
            undefined
          )}
        {this.state.lightboxHelp ? (
          <HelpModal
            help={{
              title: "The Lightbox",
              body:
                "<p>This Lightbox displays a complete set of documents in order. You can use it to go through the documents sequentially—but feel free to do them in any order that you like! Just click any thumbnail to open that document and begin marking it.</p><p>However, please note that **once you start marking a page, the Lightbox becomes locked ** until you finish marking that page! You can select a new page once you have finished.</p>"
            }}
            onDone={() => this.setState({ lightboxHelp: false })}
          />
        ) : (
            undefined
          )}
        {this.getCurrentTask() != null
          ? (() => {
            const result = [];
            const iterable = this.getCurrentTask().tool_config.options;
            for (let i = 0; i < iterable.length; i++) {
              tool = iterable[i];
              if (
                tool.help &&
                tool.generates_subject_type &&
                this.state.activeSubjectHelper === tool.generates_subject_type
              ) {
                result.push(
                  <HelpModal help={tool.help} onDone={this.hideSubjectHelp} />
                );
              } else {
                result.push(undefined);
              }
            }
            return result;
          })()
          : undefined}
      </div>
    );
  }
});

window.React = React;

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}

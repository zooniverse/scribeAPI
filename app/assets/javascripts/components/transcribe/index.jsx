/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
/** @jsx React.DOM */
const React = require("react");
const { Navigation } = require("react-router");
const SubjectViewer = require("../subject-viewer");
const JSONAPIClient = require("json-api-client"); // use to manage data?
const FetchSubjectsMixin = require("lib/fetch-subjects-mixin");
const ForumSubjectWidget = require("../forum-subject-widget");

const BaseWorkflowMethods = require("lib/workflow-methods-mixin");

// Hash of core tools:
const coreTools = require("../core-tools");

// Hash of transcribe tools:
const transcribeTools = require("./tools");

const RowFocusTool = require("../row-focus-tool");
const API = require("lib/api");

const HelpModal = require("../help-modal");
const Tutorial = require("../tutorial");
const DraggableModal = require("../draggable-modal");
const GenericButton = require("../buttons/generic-button");

module.exports = React.createClass({
  // rename to Classifier
  displayName: "Transcribe",
  mixins: [FetchSubjectsMixin, BaseWorkflowMethods, Navigation], // load subjects and set state variables: subjects,  classification

  getInitialState() {
    return {
      taskKey: null,
      classifications: [],
      classificationIndex: 0,
      subject_index: 0,
      helping: false,
      last_mark_task_key: this.props.query.mark_key,
      showingTutorial: false
    };
  },

  getDefaultProps() {
    return { workflowName: "transcribe" };
  },

  componentWillMount() {
    return this.beginClassification();
  },

  fetchSubjectsCallback() {
    if (this.getCurrentSubject() != null) {
      return this.setState({ taskKey: this.getCurrentSubject().type });
    }
  },

  __DEP__handleTaskComponentChange(val) {
    const taskOption = this.getCurrentTask().tool_config.options[val];
    if (taskOption.next_task != null) {
      return this.advanceToTask(taskOption.next_task);
    }
  },

  // Handle user selecting a pick/drawing tool:
  handleDataFromTool(d) {
    const { classifications } = this.state;
    const currentClassification =
      classifications[this.state.classificationIndex];

    // this is a source of conflict. do we copy key/value pairs, or replace the entire annotation? --STI
    for (let k in d) {
      const v = d[k];
      currentClassification.annotation[k] = v;
    }

    return this.setState({ classifications }, () => this.forceUpdate());
  },

  handleTaskComplete(d) {
    this.handleDataFromTool(d);
    return this.commitClassificationAndContinue(d);
  },

  handleViewerLoad(props) {
    let tool;
    this.setState({
      viewerSize: props.size
    });

    if ((tool = this.refs.taskComponent) != null) {
      return tool.onViewerResize(props.size);
    }
  },

  makeBackHandler() {
    return () => {
      console.log("go back");
    };
  },

  toggleHelp() {
    return this.setState({ helping: !this.state.helping });
  },

  toggleTutorial() {
    return this.setState({ showingTutorial: !this.state.showingTutorial });
  },

  hideTutorial() {
    return this.setState({ showingTutorial: false });
  },

  componentWillUnmount() {
    // PB: What's intended here? Docs state `void componentWillUnmount()`, so not sure what this serves:
    return !this.state.badSubject;
  },

  // transition back to mark workflow
  returnToMarking() {
    return this.transitionTo(
      "mark",
      {},
      {
        subject_set_id: this.getCurrentSubject().subject_set_id,
        selected_subject_id: this.getCurrentSubject().parent_subject_id,
        mark_task_key: this.props.query.mark_key,
        subject_id: this.getCurrentSubject().id,

        page: this.props.query.page
      }
    );
  },

  render() {
    let isLastSubject, transcribeMode;
    if (
      this.props.params.workflow_id != null &&
      this.props.params.parent_subject_id != null
    ) {
      transcribeMode = "page";
    } else if (this.props.params.subject_id) {
      transcribeMode = "single";
    } else {
      transcribeMode = "random";
    }

    if (this.state.subjects != null) {
      isLastSubject =
        this.state.subject_index >= this.state.subjects.length - 1;
    } else {
      isLastSubject = null;
    }

    const currentAnnotation = this.getCurrentClassification().annotation;
    const TranscribeComponent = this.getCurrentTool(); // @state.currentTool
    const onFirstAnnotation =
      (currentAnnotation != null ? currentAnnotation.task : undefined) ===
      this.getActiveWorkflow().first_task;

    return (
      <div className="classifier">
        <div className="subject-area">
          {!this.getCurrentSubject() && !this.state.noMoreSubjects ? (
            <DraggableModal
              header="Loading transcription subjects."
              buttons={<GenericButton label="Back to Marking" href="/#/mark" />}
            >
              {`\
We are currently looking for a subject for you to `}
              {this.props.workflowName}
              {`.\
`}
            </DraggableModal>
          ) : (
            undefined
          )}
          {(() => {
            if (this.state.noMoreSubjects) {
              return (
                <DraggableModal
                  header={
                    this.state.userClassifiedAll
                      ? "Thanks for transcribing!"
                      : "Nothing to transcribe"
                  }
                  buttons={<GenericButton label="Continue" href="/#/mark" />}
                >
                  {`\
Currently, there are no `}
                  {this.props.project.term("subject")}s for you to{" "}
                  {this.props.workflowName}. Try <a href="/#/mark">marking</a>
                  {` instead!\
`}
                </DraggableModal>
              );
            } else if (
              this.getCurrentSubject() != null &&
              this.getCurrentTask() != null
            ) {
              return (
                <SubjectViewer
                  onLoad={this.handleViewerLoad}
                  task={this.getCurrentTask()}
                  subject={this.getCurrentSubject()}
                  active={true}
                  workflow={this.getActiveWorkflow()}
                  classification={this.props.classification}
                  annotation={currentAnnotation}
                >
                  <TranscribeComponent
                    viewerSize={this.state.viewerSize}
                    annotation_key={`${this.state.taskKey}.${
                      this.getCurrentSubject().id
                    }`}
                    key={this.getCurrentTask().key}
                    task={this.getCurrentTask()}
                    annotation={currentAnnotation}
                    subject={this.getCurrentSubject()}
                    onChange={this.handleDataFromTool}
                    subjectCurrentPage={this.props.query.page}
                    onComplete={this.handleTaskComplete}
                    onBack={this.makeBackHandler()}
                    workflow={this.getActiveWorkflow()}
                    viewerSize={this.state.viewerSize}
                    transcribeTools={transcribeTools}
                    onShowHelp={
                      this.getCurrentTask().help != null
                        ? this.toggleHelp
                        : undefined
                    }
                    badSubject={this.state.badSubject}
                    onBadSubject={this.toggleBadSubject}
                    illegibleSubject={this.state.illegibleSubject}
                    onIllegibleSubject={this.toggleIllegibleSubject}
                    returnToMarking={this.returnToMarking}
                    transcribeMode={transcribeMode}
                    isLastSubject={isLastSubject}
                    project={this.props.project}
                  />
                </SubjectViewer>
              );
            }
          })()}
        </div>
        {(() => {
          if (this.getCurrentTask() != null && this.getCurrentSubject()) {
            const nextTask =
              __guard__(
                this.getCurrentTask().tool_config.options,
                x => x[currentAnnotation.value]
              ) != null
                ? __guard__(
                    this.getCurrentTask().tool_config.options,
                    x1 => x1[currentAnnotation.value].next_task
                  )
                : this.getCurrentTask().next_task;

            return (
              <div className="right-column">
                <div className="task-area transcribe">
                  <div className="task-secondary-area">
                    {this.getCurrentTask() != null ? (
                      <p>
                        <a
                          className="tutorial-link"
                          onClick={this.toggleTutorial}
                        >
                          View A Tutorial
                        </a>
                      </p>
                    ) : (
                      undefined
                    )}
                    <div className="forum-holder">
                      <ForumSubjectWidget
                        subject={this.getCurrentSubject()}
                        project={this.props.project}
                      />
                    </div>
                  </div>
                </div>
              </div>
            );
          }
        })()}
        {this.props.project.tutorial != null && this.state.showingTutorial ? (
          // Check for workflow-specific tutorial
          this.props.project.tutorial.workflows != null &&
          this.props.project.tutorial.workflows[
            __guard__(this.getActiveWorkflow(), x2 => x2.name)
          ] ? (
            <Tutorial
              tutorial={
                this.props.project.tutorial.workflows[
                  this.getActiveWorkflow().name
                ]
              }
              onCloseTutorial={this.hideTutorial}
            />
          ) : (
            // Otherwise just show general tutorial
            <Tutorial
              tutorial={this.props.project.tutorial}
              onCloseTutorial={this.hideTutorial}
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

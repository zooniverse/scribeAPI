/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const HelpModal = require("./help-modal");
const DraggableModal = require("./draggable-modal");

module.exports = React.createClass({
  displayName: "Tutorial",

  propTypes: {
    tutorial: React.PropTypes.object.isRequired,
    onCloseTutorial: React.PropTypes.func.isRequired
  },

  getInitialState() {
    return {
      currentTask: this.props.tutorial.first_task,
      nextTask: this.props.tutorial.tasks[this.props.tutorial.first_task]
        .next_task,
      completedSteps: 0,
      doneButtonLabel: "Next"
    };
  },

  advanceToNextTask() {
    if (this.props.tutorial.tasks[this.state.currentTask].next_task === null) {
      return this.onClose();
    } else {
      return this.setState({
        currentTask: this.state.nextTask,
        nextTask: this.props.tutorial.tasks[this.state.nextTask].next_task,
        completedSteps: this.state.completedSteps + 1
      });
    }
  },

  onClose() {
    this.animateClose();
    return this.props.onCloseTutorial();
  },

  animateClose() {
    const $modal = $(this.refs.tutorialModal.getDOMNode());
    const $clone = $modal.clone();
    const $link = $(".tutorial-link").first();
    if ($link.length) {
      const x1 = $modal.offset().left - $(window).scrollLeft();
      const y1 = $modal.offset().top - $(window).scrollTop();
      const x2 = $link.offset().left - $(window).scrollLeft();
      const y2 = $link.offset().top - $(window).scrollTop();
      const xdiff = x2 - x1;
      const ydiff = y2 - y1;
      $modal.parent().append($clone);
      return $clone.animate(
        {
          opacity: 0,
          left: `+=${xdiff}`,
          top: `+=${ydiff}`,
          width: "toggle",
          height: "toggle"
        },
        500,
        () => $clone.remove()
      );
    }
  },

  onClickStep(index) {
    const taskKeys = Object.keys(this.props.tutorial.tasks);
    const taskKey = taskKeys[index];
    const task = this.props.tutorial.tasks[taskKey];
    return this.setState({
      currentTask: taskKey,
      nextTask: task.next_task,
      completedSteps: index
    });
  },

  render() {
    let doneButtonLabel;
    const helpContent = this.props.tutorial.tasks[this.state.currentTask].help;
    const taskKeys = Object.keys(this.props.tutorial.tasks);

    if (this.state.nextTask !== null) {
      doneButtonLabel = "Next";
    } else {
      doneButtonLabel = "Done";
    }

    const progressSteps = [];
    for (let key in this.props.tutorial.tasks) {
      const step = this.props.tutorial.tasks[key];
      progressSteps.push(step);
    }

    return (
      <DraggableModal
        ref="tutorialModal"
        header={helpContent.title != null ? helpContent.title : "Help"}
        doneButtonLabel={doneButtonLabel}
        onDone={this.advanceToNextTask}
        width={800}
        classes="help-modal"
        currentStepIndex={this.state.completedSteps}
        closeButton={true}
        onClose={this.onClose}
        progressSteps={progressSteps}
        onClickStep={this.onClickStep}
      >
        <div dangerouslySetInnerHTML={{ __html: marked(helpContent.body) }} />
      </DraggableModal>
    );
  }
});

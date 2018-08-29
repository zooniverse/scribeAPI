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
const Classification = require("../models/classification.js");

const coreTools = require("../components/core-tools/index.jsx");
const markTools = require("../components/mark/tools/index.jsx");
const transcribeTools = require("../components/transcribe/tools/index.jsx");
const verifyTools = require("../components/verify/tools/index.jsx");

module.exports = {
  // Convenience method for selecting currently active workflow based on active controller
  getActiveWorkflow() {
    if (!this.props.project) {
      return null;
    }

    let k = (() => {
      const result = [];
      for (k = 0; k < this.props.project.workflows.length; k++) {
        const w = this.props.project.workflows[k];
        if (w.name === this.props.workflowName) {
          result.push(k);
        }
      }
      return result;
    })();
    if ((k != null ? k.length : undefined) !== 1) {
      return null;
    }
    return this.props.project.workflows[k[0]];
  },

  getWorkflowByName(name) {
    let k = (() => {
      const result = [];
      for (k = 0; k < this.props.project.workflows.length; k++) {
        const w = this.props.project.workflows[k];
        if (w.name === name) {
          result.push(k);
        }
      }
      return result;
    })();
    if ((k != null ? k.length : undefined) !== 1) {
      return null;
    }
    return this.props.project.workflows[k[0]];
  },

  // Start a new classification (optionally initialized with given annotation hash):
  beginClassification(annotation, callback) {
    if (annotation == null) {
      annotation = {};
    }
    const { classifications } = this.state;
    const classification = new Classification();

    if (annotation != null) {
      for (let k in annotation) {
        const v = annotation[k];
        classification.annotation[k] = v;
      }
    }

    classifications.push(classification);

    return this.setState(
      {
        classifications,
        classificationIndex: classifications.length - 1
      },
      () => {
        this.forceUpdate();
        window.classifications = this.state.classifications; // make accessible to console
        if (callback != null) {
          return callback();
        }
      }
    );
  },

  commitClassification(classification) {
    if (classification == null) {
      return;
    }

    // Create visual interim mark just in case POST takes a while
    const interim_mark = this.addInterimMark(classification);

    // Commit classification to backend
    return classification.commit(classification => {
      // Did this generate a child_subject? Update local copy:
      if (classification.child_subject) {
        this.appendChildSubject(classification.subject_id, classification.child_subject);

        // Now that we have the real mark, hide the interim mark:
        if (interim_mark != null) {
          this.hideInterimMark(interim_mark);
        }
      }

      if (this.state.badSubject) {
        this.toggleBadSubject(() => {
          return this.advanceToNextSubject();
        });
      }

      if (this.state.illegibleSubject) {
        return this.toggleIllegibleSubject(() => {
          return this.advanceToNextSubject();
        });
      }
    });
  },

  // Called immediately before saving a classification, adds a fake mark in lieu
  // of the real generated mark:
  addInterimMark(classification) {
    // Uniquely identify local interim marks:
    if (!this.interim_mark_id) {
      this.interim_mark_id = 0;
    }

    // Interim mark is the region (the mark classification's annotation hash) with extras:
    const interim_mark = $.extend(
      {
        show: true, // Default to show. We'll disable this when classification saved
        interim_id: (this.interim_mark_id += 1), // Unique id
        subject_id: classification.subject_id // Keep subject_id so we know which subject to show it over
      }, classification.annotation)

    // Add interim mark to array in @state
    const interimMarks = this.state.interimMarks != null ? this.state.interimMarks : [];
    interimMarks.push(interim_mark);
    this.setState({ interimMarks });

    return interim_mark;
  },

  // Counterpart to addInterimMark, hides the given interim mark
  hideInterimMark(interim_mark) {
    const { interimMarks } = this.state;
    return (() => {
      const result = [];
      for (let i = 0; i < interimMarks.length; i++) {
        // If this is the interim mark to hide, hide it:
        const m = interimMarks[i];
        if (m.interim_id === interim_mark.interim_id) {
          m.show = false
          this.setState({ interimMarks });
          // We found it, move on:
          break
        } else {
          result.push(undefined);
        }
      }
      return result;
    })();
  },

  // used to commit task-level classifications, i.e. not from marking tools
  commitCurrentClassification() {
    const classification = this.getCurrentClassification();
    classification.subject_id = __guard__(this.getCurrentSubject(), x => x.id);
    if (this.getCurrentSubjectSet() != null) {
      classification.subject_set_id = this.getCurrentSubjectSet().id;
    }
    classification.workflow_id = this.getActiveWorkflow().id;

    // If user activated 'Bad Subject' button, override task:
    if (this.state.badSubject) {
      classification.task_key = 'flag_bad_subject_task'
    } else if (this.state.illegibleSubject) {
      classification.task_key = 'flag_illegible_subject_task'
      // Otherwise, classification is for active task:
    } else {
      classification.task_key = this.state.taskKey;
      if (Object.keys(classification.annotation).length === 0) {
        return;
      }
    }

    this.commitClassification(classification);
    return this.beginClassification();
  },

  // used for committing marking tools (by passing annotation)
  createAndCommitClassification(annotation) {
    let { classifications } = this.state;
    const classification = new Classification();
    classification.annotation = annotation != null ? annotation : { annotation: {} }; // initialize annotation
    classification.subject_id = __guard__(this.getCurrentSubject(), x => x.id);
    if (this.getCurrentSubjectSet() != null) {
      classification.subject_set_id = this.getCurrentSubjectSet().id;
    }
    classification.workflow_id = this.getActiveWorkflow().id;

    // If user activated 'Bad Subject' button, override task:
    if (this.state.badSubject) {
      classification.task_key = 'flag_bad_subject_task'
    } else if (this.state.illegibleSubject) {
      classification.task_key = 'flag_illegible_subject_task'

      // Otherwise, classification is for active task:
    } else {
      classification.task_key = this.state.taskKey;
      if (Object.keys(classification.annotation).length === 0) {
        return;
      }
    }

    ({ classifications } = this.state);

    classifications.push(classification);

    this.setState({
      classifications: classifications,
      classificationIndex: classifications.length-1
    }, () => {
      this.forceUpdate();
      window.classifications = this.state.classifications; // make accessible to console
      if (typeof callback !== "undefined" && callback !== null) {
        return callback();
      }
    }
    );

    return this.commitClassification(classification);
  },

  toggleBadSubject(e, callback) {
    return this.setState({ badSubject: !this.state.badSubject }, () => {
      return typeof callback === "function" ? callback() : undefined;
    });
  },

  toggleIllegibleSubject(e, callback) {
    return this.setState(
      { illegibleSubject: !this.state.illegibleSubject },
      () => {
        return typeof callback === "function" ? callback() : undefined;
      }
    );
  },

  flagSubjectAsUserDeleted(subject_id) {
    const classification = this.getCurrentClassification();
    classification.subject_id = subject_id; // @getCurrentSubject()?.id
    classification.workflow_id = this.getActiveWorkflow().id;
    classification.task_key = "flag_bad_subject_task";

    return classification.commit(classification => {
      this.updateChildSubject(
        this.getCurrentSubject().id,
        classification.subject_id,
        { user_has_deleted: true }
      );
      return this.beginClassification();
    });
  },

  // Update specified child_subject with given properties (e.g. after submitting a delete flag)
  updateChildSubject(parent_subject_id, child_subject_id, props) {
    let s;
    if ((s = this.getSubjectById(parent_subject_id))) {
      return (() => {
        const result = [];
        for (let i = 0; i < s.child_subjects.length; i++) {
          var c = s.child_subjects[i];
          if (c.id === child_subject_id) {
            result.push(
              (() => {
                const result1 = [];
                for (let k in props) {
                  const v = props[k];
                  result1.push((c[k] = v));
                }
                return result1;
              })()
            );
          } else {
            result.push(undefined);
          }
        }
        return result;
      })();
    }
  },

  // Add newly acquired child_subject to child_subjects array of relevant subject (i.e. after submitting a subject-generating classification)
  appendChildSubject(subject_id, child_subject) {
    let s;
    if ((s = this.getSubjectById(subject_id))) {
      s.child_subjects.push($.extend({ userCreated: true }, child_subject));

      // We've updated an internal object in @state.subjectSets, but framework doesn't notice, so tell it to update:
      return this.forceUpdate();
    }
  },

  // Get a reference to the local copy of a subject by id regardless of whether viewing subject-sets or just subjects
  getSubjectById(id) {
    let s;
    if (this.state.subjectSets != null) {
      // If current subject set has no subjects, we're likely in between one subject set
      // and the next (for which we're currently fetching subjects), so return null:
      if (this.getCurrentSubjectSet().subjects == null) {
        return null;
      }

      for (s of Array.from(this.getCurrentSubjectSet().subjects)) {
        if (s.id === id) {
          return s;
        }
      }
    } else {
      for (s of Array.from(this.state.subjects)) {
        if (s.id === id) {
          return s;
        }
      }
    }
  },

  // Get current classification:
  getCurrentClassification() {
    return this.state.classifications[this.state.classificationIndex];
  },

  // Get current task:
  getCurrentTask() {
    if (this.state.taskKey == null) {
      return null;
    }
    if (this.getTasks()[this.state.taskKey] == null) {
      console.warn(
        `TaskKey invalid: ${this.state.taskKey}. Should be: ${(() => {
          const result = [];
          const object = this.getTasks();
          for (let k in object) {
            const v = object[k];
            result.push(k);
          }
          return result;
        })()}`
      );
    }
    return this.getTasks()[this.state.taskKey];
  },

  getTasks() {
    // Add completion_assessment_task to list of tasks dynamically:
    // <<<<<<< HEAD
    const { tasks } = this.getActiveWorkflow();
    let completion_assessment_task = this.getCompletionAssessmentTask();
    // Merge keys recursively if it exists in config
    if (tasks["completion_assessment_task"] != null) {
      completion_assessment_task = $.extend(
        true,
        tasks["completion_assessment_task"],
        completion_assessment_task
      );
    }
    return $.extend(tasks, { completion_assessment_task });
  },
  // =======
  //     tasks = @getActiveWorkflow().tasks
  //     if @props.workflowName == 'mark'
  //       tasks = $.extend tasks, completion_assessment_task: @getCompletionAssessmentTask()
  //     tasks
  // >>>>>>> master

  // Get instance of current tool:
  getCurrentTool() {
    let tool;
    const toolKey = __guard__(this.getCurrentTask(), x => x.tool);
    return (tool = this.toolByKey(toolKey));
  },

  toolByKey(toolKey) {
    let left, left1;
    return (left =
      (left1 =
        coreTools[toolKey] != null ? coreTools[toolKey] : markTools[toolKey]) !=
        null
        ? left1
        : transcribeTools[toolKey]) != null
      ? left
      : verifyTools[toolKey];
  },

  // Load next logical task
  advanceToNextTask() {
    const nextTaskKey = __guard__(this.getNextTask(), x => x.key);
    if (nextTaskKey === null) {
      return
    }

    // Commit whatever current classification is:
    this.commitCurrentClassification();
    // start a new one:
    // @beginClassification {} # this keps adding empty (uncommitted) classifications to @state.classifications --STI

    // After classification ready with empty annotation, proceed to next task:
    return this.advanceToTask(nextTaskKey);
  },

  // Get next logical task
  getNextTask() {
    let nextKey, opt, options;
    const task = this.getTasks()[this.state.taskKey];
    // PB: Moving from hash of options to an array of options

    if ((options = (() => {
        const result = [];
        for (let c of Array.from(
          task.tool_config != null ? task.tool_config.options : undefined
        )) {
          if (c.value === __guard__(this.getCurrentClassification().annotation, x => x.value)) {
            result.push(c);
          }
        }
        return result;
      })()) && options.length > 0 && (opt = options[0]) != null && opt.next_task != null) {
      nextKey = opt.next_task;
    } else {
      nextKey = this.getTasks()[this.state.taskKey].next_task;
    }

    return this.getTasks()[nextKey];
  },

  // Advance to a named task:
  advanceToTask(key) {
    const task = this.getTasks()[key];

    const tool = this.toolByKey(task != null ? task.tool : undefined);
    if (task == null) {
      return console.warn("WARN: Invalid task key: ", key);
    } else if (tool == null) {
      return console.warn(`WARN: Invalid tool specified in ${key}: ${task.tool}`);
    } else {
      return this.setState({
        taskKey: key
      });
    }
  },

  // Get currently viewed subject set
  getCurrentSubjectSet() {
    if (this.state.subjectSets != null
        ? this.state.subjectSets[this.state.subject_set_index]
        : undefined
    ) {
      return this.state.subjectSets != null
        ? this.state.subjectSets[this.state.subject_set_index]
        : undefined;
    }
  },
  // else @state.subjectSets #having a hard time accounting for one subject_set

  // Get currently viewed subject
  getCurrentSubject() {
    // If we've viewing a subject-set (i.e. Mark) let's use that subject-set's subjects

    let subjects;
    if (this.getCurrentSubjectSet() != null) {
      ({ subjects } = this.getCurrentSubjectSet());

      // Otherwise, since we're not viewing subject-sets, we must have an array of indiv subjects:
    } else {
      ({ subjects } = this.state);
    }

    // It's possible we have no subjects at all, in which case fail with null:
    if (subjects == null) {
      return null;
    }
    return subjects[this.state.subject_index];
  }, // otherwise, return subject

  getCompletionAssessmentTask() {
    return {
      generates_subject_type: null,
      instruction: `Thanks for all your work! Is there anything left to ${
        this.props.workflowName
        }?`,
      key: "completion_assessment_task",
      next_task: null,
      tool: "pickOne",
      help: {
        title: "Completion Assessment",
        body: "<p>Have all requested fields on this page been marked with a rectangle?</p><p>You do not have to mark every field on the page, however, it helps us to know if you think there is more to mark. Thank you!</p>"
      },
      tool_config: {
        "options": [
          {
            "label": "Yes",
            "next_task": null,
            "value": "incomplete_subject"
          },
          {
            "label": "No",
            "next_task": null,
            "value": "complete_subject"
          }
        ]
      },
      subToolIndex: 0
    };
  },

  // Regardless of what workflow we're in, call this to display next subject (if any avail)
  advanceToNextSubject() {
    if (this.state.subjects != null) {
      return this._advanceToNextSubjectInSubjects();
    } else {
      return this._advanceToNextSubjectInSubjectSets();
    }
  },

  // This is the version of advanceToNextSubject for workflows that consume subjects (transcribe,verify)
  _advanceToNextSubjectInSubjects() {
    if (this.state.subject_index + 1 < this.state.subjects.length) {
      const next_index = this.state.subject_index + 1;
      const next_subject = this.state.subjects[next_index];
      return this.setState({
          taskKey: next_subject.type,
          subject_index: next_index }, () => {
          const key = this.getCurrentSubject().type;
          return this.advanceToTask(key);
        }
      );

      // Haz more pages of subjects?
    } else if (this.state.subjects_next_page != null) {
      return this.fetchSubjects({ page: this.state.subjects_next_page });
    } else {
      return this.setState({
        subject_index: null,
        noMoreSubjects: true,
        userClassifiedAll: this.state.subjects.length > 0
      });
    }
  },

  // This is the version of advanceToNextSubject for workflows that consume subject sets (mark)
  _advanceToNextSubjectInSubjectSets() {
    let new_subject_set_index = this.state.subject_set_index;
    let new_subject_index = this.state.subject_index + 1;

    // If we've exhausted pages in this subject set, move to next one:
    if (new_subject_index >= this.getCurrentSubjectSet().subjects.length) {
      new_subject_set_index += 1
      new_subject_index = 0
    }

    // If we've exhausted all subject sets, collapse in shame
    if (new_subject_set_index >= this.state.subjectSets.length) {
      if (this.state.subject_sets_current_page < this.state.subject_sets_total_pages) {
        this.fetchSubjectSets({
          page: this.state.subject_sets_current_page + 1
        });
      } else {
        this.setState({
          taskKey: null,
          notice: {
            header: "All Done!",
            message: `There's nothing more for you to ${this.props.workflowName} here.`,
            onClick: () => {
              if (typeof this.context.router.transitionTo === "function") {
                this.context.router.transitionTo("mark");
              } // "/#/mark"
              return this.setState({
                notice: null,
                taskKey: this.getActiveWorkflow().first_task
              });
            }
          }
        });
        console.warn("NO MORE SUBJECT SETS");
      }
      return
    }

    // console.log "Mark#index Advancing to subject_set_index #{new_subject_set_index} (of #{@state.subjectSets.length}), subject_index #{new_subject_index} (of #{@state.subjectSets[new_subject_set_index].subjects.length})"

    return this.setState(
      {
        subject_set_index: new_subject_set_index,
        subject_index: new_subject_index,
        taskKey: this.getActiveWorkflow().first_task,
        currentSubToolIndex: 0
      },
      () => {
        return this.fetchSubjectsForCurrentSubjectSet(1, 100);
      }
    );
  },

  commitClassificationAndContinue(d) {
    this.commitCurrentClassification();
    return this.beginClassification({}, () => {
      if (__guard__(this.getCurrentTask(), x => x.next_task) != null) {
        return this.advanceToTask(this.getCurrentTask().next_task);
      } else {
        return this.advanceToNextSubject();
      }
    });
  }
};

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}

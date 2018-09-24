export default class Classification {
  constructor() {
    this.metadata = {
      started_at: (new Date).toISOString()
    };
    this.annotation = {};
    this.subject_id = null;
    this.subject_set_id = null;
    this.task_key = null;

    this.generates_subject_type = null;
    this.toolName = null;
    this.committed = false;
  }

  commit(callback) {
    // only commit the classification if it isn't already committed or
    // the classification is flagging a subject as bad.
    if (this.committed && this.task_key !== "flag_bad_subject_task") {
      return;
    }
    this.committed = true;

    this.metadata.finished_at = new Date().toISOString();
    const data = {
      classifications: {
        annotation: this.annotation,
        subject_id: this.subject_id,
        subject_set_id: this.subject_set_id,
        task_key: this.task_key,
        metadata: this.metadata,
        workflow_id: this.workflow_id
      }
    };

    $.ajax("/classifications", {
      data: data,
      method: 'post',
      dataType: 'json',
      complete: (resp) => {
        typeof callback === "function" ?
          callback(
            resp.responseJSON != null ?
            resp.responseJSON.classification :
            undefined
          ) : undefined;
      }
    });
  }
}
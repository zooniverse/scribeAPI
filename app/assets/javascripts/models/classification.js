/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
class Classification {
  constructor() {
    this.metadata = {
      started_at: (new Date).toISOString()
    };
    this.annotation = {};
    this.subject_id = null;
    this.subject_set_id = null;
    this.task_key = null;

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

    return $.ajax("/classifications", {
      data: data,
      method: 'post',
      dataType: 'json',
      complete: (resp) => {
        return typeof callback === "function"
          ? callback(
            resp.responseJSON != null
              ? resp.responseJSON.classification
              : undefined
          )
          : undefined;
      }
    });
  }
}

// $.ajax('/classifications', data: data, method: 'post', dataType: 'json').done((response)->
//   console.log 'success: ', response
//   callback? response.responseJSON?.classification
//   return
// ).fail(->
//   console.log 'error'
//   return
// ).always(->
//   console.log 'complete (always)'
//   return
// )

// console.log 'Classification::commit() END'
// # Perform other work here ...
// # Set another completion function for the request above
// jqxhr.always ->
//   alert 'second complete'
//   return

// rec.save()
// rec = API.type('classifications').create
//   annotation: @annotation
//   subject_id: @subject_id
//   subject_set_id: @subject_set_id
//   task_key: @task_key
//   metadata: @metadata
//   workflow_id: @workflow_id
// rec.save()

export default Classification;

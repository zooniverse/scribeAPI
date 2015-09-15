class Classification

  constructor: ->
    @metadata =
      started_at: (new Date).toISOString()
    @annotation = {}
    @subject_id = null
    @subject_set_id = null
    @task_key = null

    @annotation = {}
    @subject_id = null
    @subject_set_id = null
    @task_key = null
    @generates_subject_type = null
    @toolName = null
    @committed = false

  commit: (callback) ->
    console.log 'Classification::commit()'

    console.log 'COMMIT flag was set to: ', @committed

    if @committed  # this flag doesn't seem to be used anywhere --STI
      console.log 'ALREADY SUBMITTED THIS CLASSIFICATION!'
      return

    @committed = true

    console.log 'set COMMITTED flag to: ', @committed
    console.log 'ANNOTATION: ', @annotation
    @metadata.finished_at = (new Date).toISOString()
    data =
      classifications:
        annotation: @annotation
        subject_id: @subject_id
        subject_set_id: @subject_set_id
        task_key: @task_key
        metadata: @metadata
        workflow_id: @workflow_id

    $.ajax "/classifications",
      data: data
      method: 'post'
      dataType: 'json'
      complete: (resp) =>
        callback? resp.responseJSON?.classification

    """
    rec.save()
    rec = API.type('classifications').create
      annotation: @annotation
      subject_id: @subject_id
      subject_set_id: @subject_set_id
      task_key: @task_key
      metadata: @metadata
      workflow_id: @workflow_id
    rec.save()
    """

module.exports = Classification

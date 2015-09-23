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
    console.log 'Classification::commit()', @committed
    return if @committed
    @committed = true

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
        console.log 'RESP: ', resp
        callback? resp.responseJSON?.classification

    # $.ajax('/classifications', data: data, method: 'post', dataType: 'json').done((response)->
    #   console.log 'success: ', response
    #   callback? response.responseJSON?.classification
    #   return
    # ).fail(->
    #   console.log 'error'
    #   return
    # ).always(->
    #   console.log 'complete (always)'
    #   return
    # )

    console.log 'Classification::commit() END'
    # # Perform other work here ...
    # # Set another completion function for the request above
    # jqxhr.always ->
    #   alert 'second complete'
    #   return


    # rec.save()
    # rec = API.type('classifications').create
    #   annotation: @annotation
    #   subject_id: @subject_id
    #   subject_set_id: @subject_set_id
    #   task_key: @task_key
    #   metadata: @metadata
    #   workflow_id: @workflow_id
    # rec.save()

module.exports = Classification

class Classification

  constructor: (subject) ->
    @started_at = (new Date).toUTCString()
    @subject = subject
    @user_agent = window.navigator.userAgent
    @annotations ?= []

  annotate: (annotation) ->
    console.log 'FOO!'
    @annotations.push annotation
    return annotation

  toJSON: ->
    subject_id = @subject.id

    output = classification:
      subject: @subject
      annotations: @annotations.concat [{@started_at, @finished_at}, {@user_agent}]

    for key, value of @generic
      annotation = {}
      annotation[key] = value
      output.classification.annotations.push annotation

    return output

  send: ->
    @finished_at = (new Date).toUTCString()
    # TODO: Post request goes here


window.Classification = Classification

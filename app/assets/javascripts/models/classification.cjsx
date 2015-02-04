class Classification

  constructor: (subject) ->
    console.log 'SUBJECT: ', subject
    @started_at = (new Date).toUTCString()
    @subject = subject
    @subject_id = subject.subject_id
    @user_agent = window.navigator.userAgent
    @annotations ?= []

  annotate: (annotation) ->
    @annotations.push annotation
    return annotation

  toJSON: (workflow_id) ->    
    subject_id = @subject.id

    return result = 
      workflow_id: workflow_id
      subject:     @subject
      annotations: @annotations #.concat [{@started_at, @finished_at}, {@user_agent}]
      user_agent:  @user_agent

      # TODO: incorrect timestamps
      # started_at: @started_at
      # finished_at: (new Date).toUTCString()    

module.exports = Classification
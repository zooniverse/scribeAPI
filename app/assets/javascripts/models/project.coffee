class Project

  constructor: (obj) ->
    for k,v of obj
      @[k] = v

  term: (t) ->
    @terms_map[t] ? t

  workflowWithMostActives: (not_named = '') ->
    (w for w in @mostActiveWorkflows() when w.name != not_named)[0]

  mostActiveWorkflows: ->
    @workflows.sort (w1, w2) ->
      return -1 if w1.active_subjects > w2.active_subjects
      1

module.exports = Project

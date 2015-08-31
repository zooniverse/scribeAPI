class Project

  constructor: (obj) ->
    for k,v of obj
      @[k] = v

  term: (t) ->
    @terms_map[t] ? t

module.exports = Project

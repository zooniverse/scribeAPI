String::capitalize = ->
  @replace /^./, (match) ->
      match.toUpperCase()

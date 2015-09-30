String::capitalize = ->
  @replace /^./, (match) ->
      match.toUpperCase()

String::truncate = (max, add="...") ->
  if @length > max
    @substring(0,max) + add
  else
    @

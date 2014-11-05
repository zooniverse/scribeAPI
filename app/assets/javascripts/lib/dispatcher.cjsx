stores = []

register = (store) ->
  stores.push store

dispatch = (action, payload...) ->
  unless process.env.NODE_ENV is 'production'
    console?.info 'Dispatching', action, 'with', payload...

    unless action.indexOf(':') > -1
      console?.warn "Dispatched actions (`#{action}`) should have a colon in them to disambiguate them from regular store methods."

  for store in stores when store[action]?
    anyHandlerMatched = true
    # NOTE: If the handler returns a promise, this will wait to emit until it resolves, otheriwse it emits immediately.
    handledValue = store[action] payload...
    Promise.all([handledValue]).then store.emitChange.bind store

  unless process.env.NODE_ENV is 'production'
    unless anyHandlerMatched
      console?.warn "No stores respond to the action `#{action}`."

module.exports = {register, dispatch}
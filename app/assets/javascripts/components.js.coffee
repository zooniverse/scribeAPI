React = require("react")
# { Router, Route, Link, HashHistory } = require('react-router')

Router = require('react-router')
{Handler, Root, RouteHandler, Route, DefaultRoute, Navigation, Link} = Router
BrowserHistory = require 'react-router/lib/BrowserHistory'

# Because we're calling a component directly, need to wrap in factory call ( https://gist.github.com/sebmarkbage/ae327f2eda03bf165261 ):
# App = require("./components/appnewer")
# App = require("./components/appnew")

Foo1 = React.createClass
  displayName: 'Foo1'
  render: ->
    <div>Foo 1 page</div>

Foo2 = React.createClass
  displayName: 'Foo2'
  render: ->
    <div>Foo 2 page</div>

NoMatch = React.createClass
  displayName: 'NoMatch'
  render: ->
    <div>No match</div>


$(document).ready ->

  console.log "fucking router: ", Router
  React.render (
    <Router history={BrowserHistory}>
      <Route path="/" component={Foo1}>
        <Route path="foo2" component={Foo2}/>
        <Route path="*" component={NoMatch}/>
      </Route>
    </Router>), document.getElementById('react-target')

  # el = React.render(App({}), document.body)

  # console.log "here: ", el

  # React.render React.createElement(App), document.getElementById('react-target') # body
  # React.createElement(App)
  """
  React.render((
    <Router>
      <Route path="/" component={App}>
      </Route>
    </Router>
  ), document.body)
  """



React = require("react")
Router = require 'react-router'
{Handler, Root, RouteHandler, Route, DefaultRoute, Navigation, Link} = Router

BrowserHistory = require 'react-router/lib/BrowserHistory'

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


App = React.createClass
  displayName: 'App'
  render: ->
    <Router>
      <Route path="/" component={Foo1}>
        <Route path="foo2" component={Foo2}/>
        <Route path="*" component={NoMatch}/>
      </Route>
    </Router>

module.exports = App

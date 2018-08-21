/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const Router = require("react-router");
const {
  Handler,
  Root,
  RouteHandler,
  Route,
  DefaultRoute,
  Navigation,
  Link
} = Router;

const BrowserHistory = require("react-router/lib/BrowserHistory");

const Foo1 = React.createClass({
  displayName: "Foo1",
  render() {
    return <div>Foo 1 page</div>;
  }
});

const Foo2 = React.createClass({
  displayName: "Foo2",
  render() {
    return <div>Foo 2 page</div>;
  }
});

const NoMatch = React.createClass({
  displayName: "NoMatch",
  render() {
    return <div>No match</div>;
  }
});

const App = React.createClass({
  displayName: "App",
  render() {
    return (
      <Router>
        <Route path="/" component={Foo1}>
          <Route path="foo2" component={Foo2} />
          <Route path="*" component={NoMatch} />
        </Route>
      </Router>
    );
  }
});

module.exports = App;

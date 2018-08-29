/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const Router, { Route } = require("react-router");
const createReactClass = require("create-react-class");

const Foo1 = createReactClass({
  displayName: "Foo1",
  render() {
    return <div>Foo 1 page</div>;
  }
});

const Foo2 = createReactClass({
  displayName: "Foo2",
  render() {
    return <div>Foo 2 page</div>;
  }
});

const NoMatch = createReactClass({
  displayName: "NoMatch",
  render() {
    return <div>No match</div>;
  }
});

const App = createReactClass({
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

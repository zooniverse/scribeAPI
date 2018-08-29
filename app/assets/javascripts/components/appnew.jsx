/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const { RouteHandler } = require("react-router");
const createReactClass = require("create-react-class");
const MainHeader = require("../partials/main-header.jsx");
const API = require("../lib/api.jsx");
const AppRouter = require("./app-router.jsx");


window.API = API;

const App = createReactClass({
  getInitialState() {
    return {
      project: null,
      routerRunning: false
    };
  },

  componentDidMount() {
    if (this.state.project == null) {
      return API.type("projects")
        .get()
        .then(result => {
          const project = result[0];

          return this.setState({ project });
        });
    }
  },

  render() {
    if (this.state.project == null) {
      return null;
    }

    const style = {};
    if (this.state.project.background != null) {
      style.backgroundImage = `url(${this.state.project.background})`;
    }

    return (
      <div>
        <div className="readymade-site-background" style={style}>
          <div className="readymade-site-background-effect" />
        </div>
        <div className="panoptes-main">
          <MainHeader
            workflows={this.state.project.workflows}
            pages={this.state.project.pages}
            short_title={this.state.project.short_title}
          />
          <div className="main-content">
            <RouteHandler
              hash={window.location.hash}
              project={this.state.project}
            />
          </div>
        </div>
      </div>
    );
  }
});

module.exports = App;

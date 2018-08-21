/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const MainHeader = require("../partials/main-header");
const Footer = require("../partials/footer");
const API = require("../lib/api");
const Project = require("../models/project.coffee");

const BrowserWarning = require("./browser-warning");

const { RouteHandler } = require("react-router");

window.API = API;

const App = React.createClass({
  getInitialState() {
    return {
      routerRunning: false,
      user: null,
      loginProviders: []
    };
  },

  componentDidMount() {
    return this.fetchUser();
  },

  fetchUser() {
    this.setState({
      error: null
    });
    const request = $.getJSON("/current_user");

    request.done(result => {
      if (result != null ? result.data : undefined) {
        this.setState({
          user: result.data
        });
      } else {
      }

      if (__guard__(result != null ? result.meta : undefined, x => x.providers)) {
        return this.setState({ loginProviders: result.meta.providers });
      }
    });

    return request.fail(error => {
      return this.setState({
        loading: false,
        error: "Having trouble logging you in"
      });
    });
  },

  setTutorialComplete() {
    const previously_saved =
      (this.state.user != null
        ? this.state.user.tutorial_complete
        : undefined) != null;

    // Immediately ammend user object with tutorial_complete flag so that we can hide the Tutorial:
    this.setState({
      user: $.extend(this.state.user != null ? this.state.user : {}, {
        tutorial_complete: true
      })
    });

    // Don't re-save user.tutorial_complete if already saved:
    if (previously_saved) {
      return;
    }

    const request = $.post("/tutorial_complete");
    return request.fail(error => {
      return console.log("failed to set tutorial value for user");
    });
  },

  render() {
    const { project } = window;
    if (project == null) {
      return null;
    }

    const style = {};
    if (project.background != null) {
      style.backgroundImage = `url(${project.background})`;
    }

    return (
      <div>
        <div className="readymade-site-background" style={style}>
          <div className="readymade-site-background-effect"></div>
        </div>
        <div className="panoptes-main">
          <MainHeader
            workflows={project.workflows}
            feedbackFormUrl={project.feedback_form_url}
            discussUrl={project.discuss_url}
            blogUrl={project.blog_url}
            pages={project.pages}
            short_title={project.short_title}
            logo={project.logo}
            menus={project.menus}
            user={this.state.user}
            loginProviders={this.state.loginProviders}
            onLogout={() => this.setState({ user: null })}
          />
          <div className="main-content">
            <BrowserWarning />
            <RouteHandler
              hash={window.location.hash}
              project={project}
              onCloseTutorial={this.setTutorialComplete}
              user={this.state.user}
            />
          </div>
          <Footer
            privacyPolicy={project.privacy_policy}
            menus={project.menus}
            partials={project.partials}
          />
        </div>
      </div>
    );
  }
});

module.exports = App;

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}

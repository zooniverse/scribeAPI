/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");

const Login = React.createClass({
  displayName: "Login",

  getInitialState() {
    return { error: null };
  },

  getDefaultProps() {
    return {
      user: null,
      loginProviders: []
    };
  },

  render() {
    return (
      <div className="login">
        {(this.props.user != null ? this.props.user.name : undefined) != null &&
        !this.props.user.guest
          ? this.renderLoggedIn()
          : undefined}
        {this.props.user && this.props.user.guest
          ? this.renderLoggedInAsGuest()
          : undefined}
        {!this.props.user
          ? this.renderLoginOptions("Log In:", "login-container")
          : undefined}
      </div>
    );
  },

  signOut(e) {
    e.preventDefault();

    const request = $.ajax({
      url: "/users/sign_out",
      method: "delete",
      dataType: "json"
    });

    request.done(() => {
      return this.props.onLogout();
    });

    return request.error((request, error) => {
      return this.setState({
        error: "Could not log out"
      });
    });
  },

  renderLoggedInAsGuest() {
    return (
      <span>
        {this.renderLoginOptions(
          "Log in to save your work:",
          "login-container"
        )}
      </span>
    );
  },

  renderLoggedIn() {
    return (
      <span className="login-container">
        {this.props.user.avatar ? (
          <img src={`${this.props.user.avatar}`} />
        ) : (
          undefined
        )}
        <span className="label">Hello {this.props.user.name} </span>
        <a className="logout" onClick={this.signOut}>
          Logout
        </a>
      </span>
    );
  },

  renderLoginOptions(label, classNames) {
    const links = this.props.loginProviders.map(function(link) {
      const icon_id = link.id === "zooniverse" ? "dot-circle-o" : link.id;
      return (
        <a
          key={`login-link-${link.id}`}
          href={link.path}
          title={`Log in using ${link.name}`}
        >
          <i className={`fa fa-${icon_id} fa-2`} />
        </a>
      );
    });

    return (
      <span className={classNames}>
        <span className="label">{label || "Log In:"}</span>
        <div className="options">{links}</div>
      </span>
    );
  }
});

module.exports = Login;

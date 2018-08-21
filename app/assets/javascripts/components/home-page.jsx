/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const React = require("react");
const GroupBrowser = require("./group-browser");
const NameSearch = require("./name-search");
const { Navigation } = require("react-router");

const HomePage = React.createClass({
  displayName: "HomePage",
  mixins: [Navigation],

  componentWillReceiveProps(new_props) {
    return this.setState({ project: new_props.project });
  },

  markClick() {
    return this.transitionTo("mark", {});
  },

  transcribeClick() {
    return this.transitionTo("transcribe", {});
  },

  render() {
    return (
      <div className="home-page">
        {(this.props.project != null
          ? this.props.project.home_page_content
          : undefined) != null ? (
          <div className="page-content">
            <h1 className="title">
              {this.props.project != null
                ? this.props.project.title
                : undefined}
            </h1>
            <div
              dangerouslySetInnerHTML={{
                __html: marked(this.props.project.home_page_content)
              }}
            />
            {// Is there a metadata search configured, and should it be on the homepage?
            // TODO If mult metadata_search fields configured, maybe offer a <select> to choose between them
            __guard__(
              this.props.project != null
                ? this.props.project.metadata_search
                : undefined,
              x => x.feature_on_homepage
            )
              ? Array.from(this.props.project.metadata_search.fields).map(
                  field => (
                    <div className="metadata-search" key={field}>
                      <img id="search-icon" src="assets/searchtool.svg" />
                      <NameSearch field={field.field} />
                    </div>
                  )
                )
              : undefined}
            <div className="group-area">
              <GroupBrowser project={this.props.project} />
            </div>
          </div>
        ) : (
          undefined
        )}
      </div>
    );
  }
});

module.exports = HomePage;

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}

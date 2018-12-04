/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

import React from "react";
import marked from '../lib/marked.min.js';
import { AppContext } from "./app-context.jsx";
import GroupBrowser from "./group-browser.jsx";
import NameSearch from "./name-search.jsx";

@AppContext
export default class HomePage extends React.Component {
  componentWillReceiveProps(new_props) {
    return this.setState({ project: new_props.project });
  }

  markClick() {
    return this.props.context.router.transitionTo("mark", {});
  }

  transcribeClick() {
    return this.props.context.router.transitionTo("transcribe", {});
  }

  render() {
    return (
      <div className="home-page">
        {this.props.context.project != null &&
          this.props.context.project.home_page_content != null &&
          <div className="page-content">
            <h1 className="title">
              {this.props.context.project != null
                ? this.props.context.project.title
                : undefined}
            </h1>
            <div
              dangerouslySetInnerHTML={{
                __html: marked(this.props.context.project.home_page_content)
              }}
            />
            {// Is there a metadata search configured, and should it be on the homepage?
              // TODO If mult metadata_search fields configured, maybe offer a <select> to choose between them
              __guard__(
                this.props.context.project != null
                  ? this.props.context.project.metadata_search
                  : undefined,
                x => x.feature_on_homepage
              )
                ? Array.from(this.props.context.project.metadata_search.fields).map(
                  field => (
                    <div className="metadata-search" key={field}>
                      <img id="search-icon" src="assets/searchtool.svg" />
                      <NameSearch field={field.field} />
                    </div>
                  )
                )
                : undefined}
            <div className="group-area">
              <GroupBrowser project={this.props.context.project} />
            </div>
          </div>}
      </div>
    );
  }
}

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}

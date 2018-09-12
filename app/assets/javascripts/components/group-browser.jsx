/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react";
import createReactClass from "create-react-class";
import API from "../lib/api.jsx";

const GroupBrowser = createReactClass({
  displayName: "GroupBrowser",

  getInitialState() {
    return { groups: [] };
  },

  componentDidMount() {
    return API.type("groups")
      .get({ project_id: this.props.project.id })
      .then(groups => {
        for (let group of Array.from(groups)) {
          group.showButtons = false;
        } // hide buttons by default
        return this.setState({ groups });
      });
  },

  showButtonsForGroup(group, e) {
    group.showButtons = true;
    return this.forceUpdate();
  }, // trigger re-render to update buttons

  hideButtonsForGroup(group, e) {
    group.showButtons = false;
    return this.forceUpdate();
  }, // trigger re-render to update buttons

  renderGroup(group) {
    const buttonContainerClasses = [];
    const groupNameClasses = [];
    if (group.showButtons) {
      buttonContainerClasses.push("active");
    } else {
      groupNameClasses.push("active");
    }

    return (
      <div
        onMouseOver={this.showButtonsForGroup.bind(this, group)}
        onMouseOut={this.hideButtonsForGroup.bind(this, group)}
        className="group"
        style={{ backgroundImage: `url(${group.cover_image_url})` }}
        key={group.id}
      >
        <div className={`button-container ${buttonContainerClasses.join(" ")}`}>
          {(() => {
            const result = [];
            for (let workflow of Array.from(this.props.project.workflows)) {
              if (
                (__guard__(
                  group.stats.workflow_counts != null
                    ? group.stats.workflow_counts[workflow.id]
                    : undefined,
                  x => x.active_subjects
                ) != null
                  ? __guard__(
                      group.stats.workflow_counts != null
                        ? group.stats.workflow_counts[workflow.id]
                        : undefined,
                      x => x.active_subjects
                    )
                  : 0) > 0
              ) {
                result.push(
                  <a
                    href={`/#/${workflow.name}?group_id=${group.id}`}
                    className="button small-button"
                    key={workflow.id}
                  >
                    {workflow.name.capitalize()}
                  </a>
                );
              } else {
                result.push(undefined);
              }
            }

            return result;
          })()}
          <a
            href={`/#/groups/${group.id}`}
            className="button small-button ghost"
          >
            More info
          </a>
        </div>
        <p className={`group-name ${groupNameClasses.join(" ")}`}>
          {group.name}
        </p>
      </div>
    );
  },

  render() {
    // Only display GroupBrowser if more than one group defined:
    if (this.state.groups.length <= 1) {
      return null;
    }

    const groups = [
      Array.from(this.state.groups).map(group => this.renderGroup(group))
    ];
    return (
      <div className="group-browser">
        <h3 className="groups-header">
          {this.props.title != null ? (
            <span>{this.props.title}</span>
          ) : (
            <span>Select a {this.props.project.term("group")}</span>
          )}
        </h3>
        <div className="groups">{groups}</div>
      </div>
    );
  }
});

export default GroupBrowser;

function __guard__(value, transform) {
  return typeof value !== "undefined" && value !== null
    ? transform(value)
    : undefined;
}

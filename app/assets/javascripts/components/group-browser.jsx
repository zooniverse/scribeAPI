import React from "react";
import { NavLink } from 'react-router-dom';
import API from "../lib/api.jsx";
import { AppContext } from "./app-context.jsx";

@AppContext
export default class GroupBrowser extends React.Component {
  constructor() {
    super();
    this.state = { counts: {}, groups: [] };
  }

  componentDidMount() {
    const project_id = this.props.project.id;
    API.type("groups")
      .get({ project_id })
      .then(groups => {
        for (let group of groups) {
          // hide buttons by default
          group.showButtons = false;
        }
        this.setState({ groups });

        for (let group of this.state.groups) {
          API.type("subject_sets")
            .get({ group_id: group.id })
            .then(sets => {
              const counts = {
                [group.id]: sets[0].counts,
                ... this.state.counts
              };
              this.setState({ counts });
            });
        }
      });
  }

  showButtonsForGroup(group, e) {
    group.showButtons = true;
    // trigger re-render to update buttons
    this.forceUpdate();
  }

  hideButtonsForGroup(group, e) {
    group.showButtons = false;
    // trigger re-render to update buttons
    this.forceUpdate();
  }

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
            const groupCounts = this.state.counts[group.id] != null &&
              this.state.counts[group.id];
            if (groupCounts) {
              for (let workflow of this.props.project.workflows) {
                const workflowCounts = groupCounts[workflow.id] != null &&
                  groupCounts[workflow.id];
                if ((workflowCounts != null && workflowCounts.active_subjects
                  ? workflowCounts.active_subjects
                  : 0) > 0
                ) {
                  result.push(
                    <NavLink to={`/${workflow.name}?group_id=${group.id}`}
                      className="button small-button"
                      key={workflow.id}>
                      {workflow.name.capitalize()}
                    </NavLink>
                  );
                }
              }
            }

            return result;
          })()}
          <NavLink to={`/groups/${group.id}`} className="button small-button ghost">More info</NavLink>
        </div>
        <p className={`group-name ${groupNameClasses.join(" ")}`}>{group.name}</p>
      </div>
    );
  }

  render() {
    // Only display GroupBrowser if more than one group defined:
    if (this.state.groups.length <= 1) {
      return null;
    }

    const groups = [
      this.state.groups.map(group => this.renderGroup(group))
    ];
    return (
      <div className="group-browser">
        <h3 className="groups-header">
          {this.props.title != null &&
            <span>{this.props.title}</span> ||
            <span>Select a {this.props.project.term("group")}</span>}
        </h3>
        <div className="groups">{groups}</div>
      </div>
    );
  }
};

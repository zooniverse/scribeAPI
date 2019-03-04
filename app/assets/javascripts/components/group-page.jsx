import React from 'react'
import GenericButton from './buttons/generic-button.jsx'
import API from '../lib/api.jsx'
import { AppContext } from './app-context.jsx'

@AppContext
export default class GroupPage extends React.Component {
  constructor() {
    super()
    this.state = { group: null }
  }

  componentDidMount() {
    API.type('groups')
      .get(this.props.match.params.group_id)
      .then(group => {
        this.setState({
          group
        })
      })

    API.type('subject_sets')
      .get({ group_id: this.props.match.params.group_id })
      .then(sets => {
        this.setState({
          subject_sets: sets
        })
      })
  }

  render() {
    if (this.state.group == null) {
      return (
        <div className="group-page">
          <h2>Loading...</h2>
        </div>
      )
    }
    return (
      <div className="page-content">
        <h1>{this.state.group.name}</h1>
        <div className="group-page">
          <div className="group-information">
            <h3>{this.state.group.description}</h3>
            <dl className="metadata-list">
              {(() => {
                const result = []
                for (let k in this.state.group.meta_data) {
                  // Is there another way to return both dt and dd elements without wrapping?
                  const v = this.state.group.meta_data[k]
                  if (
                    [
                      'key',
                      'description',
                      'cover_image_url',
                      'external_url',
                      'retire_count'
                    ].indexOf(k) < 0
                  ) {
                    result.push(
                      <div key={k}>
                        <dt>{k.replace(/_/g, ' ')}</dt>
                        <dd>{v}</dd>
                      </div>
                    )
                  }
                }

                return result
              })()}
              {this.state.group.meta_data.external_url != null ? (
                <div>
                  <dt>External Resource</dt>
                  <dd>
                    <a
                      href={this.state.group.meta_data.external_url}
                      target="_blank"
                    >
                      {this.state.group.meta_data.external_url}
                    </a>
                  </dd>
                </div>
              ) : (
                undefined
              )}
            </dl>
            <img
              className="group-image"
              src={this.state.group.cover_image_url}
            />
          </div>
          <div className="group-stats">
            {this.state.group.stats != null ? (
              <div>
                <dl className="stats-list">
                  <div>
                    <dt>Classifications In-Progress</dt>
                    <dd>
                      {(this.state.group.stats != null
                        ? this.state.group.stats.total_pending
                        : undefined) != null
                        ? this.state.group.stats != null
                          ? this.state.group.stats.total_pending
                          : undefined
                        : 0}
                    </dd>
                  </div>
                  <div>
                    <dt>Complete Classifications</dt>
                    <dd>
                      {(this.state.group.stats != null
                        ? this.state.group.stats.total_finished
                        : undefined) != null
                        ? this.state.group.stats != null
                          ? this.state.group.stats.total_finished
                          : undefined
                        : 0}
                    </dd>
                  </div>
                  <div>
                    <dt>Overall Estimated Completion</dt>
                    <dd>
                      {parseInt(
                        ((this.state.group.stats != null
                          ? this.state.group.stats.completeness
                          : undefined) != null
                          ? this.state.group.stats != null
                            ? this.state.group.stats.completeness
                            : undefined
                          : 0) * 100
                      )}
                      %
                    </dd>
                  </div>
                </dl>
              </div>
            ) : (
              undefined
            )}
            <div className="subject_sets">
              {(
                this.state.subject_sets != null ? this.state.subject_sets : []
              ).map((set, i) => (
                <div key={i} className="subject_set">
                  <div className="mark-transcribe-buttons">
                    {(() => {
                      const result1 = []
                      for (let workflow of this.props.context.project.workflows) {
                        const workflowCounts = set.counts[workflow.id] != null &&
                          set.counts[workflow.id]
                        if ((workflowCounts != null && workflowCounts.active_subjects
                          ? workflowCounts.active_subjects
                          : 0) > 0
                        ) {
                          result1.push(
                            <GenericButton
                              key={workflow.id}
                              label={workflow.name}
                              to={`/${workflow.name}?subject_set_id=${
                                set.id
                              }`}
                            />
                          )
                        } else {
                          result1.push(undefined)
                        }
                      }

                      return result1
                    })()}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    )
  }
}

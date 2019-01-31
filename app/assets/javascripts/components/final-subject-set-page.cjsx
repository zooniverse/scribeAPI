React = require 'react'
API   = require '../lib/api'

GenericButton   = require('components/buttons/generic-button')

module.exports = React.createClass
  displayName: 'FinalSubjectSetPage'

  getInitialState:->
    set: null

  componentDidMount: ->
    API.type("final_subject_sets").get(@props.params.final_subject_set_id).then (set) =>
      @setState
        set: set

  render: ->
    return null if ! @state.set

    <div className="page-content final-subject-set-browser">
      <div className="final-subject-set-page">
        <a className="standard-button json-link" href="/final_subject_sets/#{@state.set.id}.json" target="_blank">Download Raw Data</a>
        <h2>Set {@state.set.id}</h2>

        <ul>
          { for subject in @state.set.subjects
              <li className="final-subject-set" key={subject.id}>
                <img src={subject.location.standard} className="standard-image"/>
                <ul>
                  {
                    assertions = subject.assertions.sort (a1,a2) ->
                      if a1.region.y < a2.region.y
                        -1
                      else
                        1
                    null
                  }
                  { for assertion,i in assertions when assertion.name
                      <li key={i}>
                        <h3>{assertion.name}</h3>

                        <ul className="assertion-data">
                        { for k of assertion.data
                            console.log "assertion data: ", k, assertion.data
                            <li key={k}>
                              <span className="value">{assertion.data[k]}</span>
                              { if k != 'value'
                                  <span className="data-key">({k.replace /_/g, ' '})</span>
                              }
                            </li>
                        }
                        </ul>
                        <dl className="assertion-properties">
                          <dt>Confidence</dt>
                          <dd>{Math.round(100 * assertion.confidence)}%</dd>
                          <dt>Status</dt>
                          <dd>{assertion.status.replace /_/, ' '}</dd>
                          <dt>Distinct Classifications</dt>
                          <dd>{assertion.classifications?.length || 0}</dd>
                        </dl>
                        {
                          viewer_width = assertion.region.width
                          scale = viewer_width / assertion.region.width
                          s =
                            background: "url(#{subject.location.standard}) no-repeat -#{Math.round(assertion.region.x * scale)}px -#{Math.round(assertion.region.y * scale)}px"
                            width: viewer_width + 'px'
                            height: Math.round(assertion.region.height * scale) + 'px'
                          <div className="image-crop" src={subject.location.standard} style={s} />
                        }
                      </li>
                  }
                </ul>

              </li>
          }
        </ul>
      </div>
    </div>


React = require 'react'
API   = require '../lib/api'

FinalSubjectAssertion = require('components/final-subject-assertion')

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
                    # Sort assertions by order they appear in document:
                    assertions = subject.assertions.sort (a1,a2) ->
                      if a1.region.y < a2.region.y
                        -1
                      else
                        1
                    null
                  }
                  { for assertion,i in assertions when assertion.name
                      <li key={i}>
                        <FinalSubjectAssertion subject={subject} assertion={assertion} project={@props.project} />
                      </li>
                  }
                </ul>

              </li>
          }
        </ul>
      </div>
    </div>


React                     = require 'react'
API                       = require '../lib/api'
GenericPage               = require './generic-page'
FetchProjectMixin         = require 'lib/fetch-project-mixin'

FinalSubjectAssertion     = require('components/final-subject-assertion')


module.exports = React.createClass
  displayName: 'FinalSubjectSetPage'
  
  mixins: [FetchProjectMixin]

  getInitialState:->
    set: null
    tab: null
    tabs: []

  componentDidMount: ->
    API.type("final_subject_sets").get(@props.params.final_subject_set_id).then (set) =>
      tabs = []
      tabs.push 'export-doc' if set.export_document
      tabs.push 'source-metadata' if set.meta_data
      tabs.push 'assertions'
      @setState
        set: set
        tab: tabs[0]
        tabs: tabs

  showExportDoc: ->
    @showTab 'export-doc'

  showAssertions: ->
    @showTab 'assertions'

  showTab: (which) ->
    @setState tab: which


  render: ->
    return null if ! @state.set

    data_nav = @state.project.page_navs['data']

    <GenericPage key='final-subject-set-browser' title="Data Exports" nav={data_nav} current_nav="/#/data/browse">
      <div className="final-subject-set-browser">
        <div className="final-subject-set-page">

          <a href={"/#/data/browse?keyword=#{@props.query.keyword}&field=#{@props.query.field ? ''}"} className="back">Back</a>

          <a className="standard-button json-link" href="/final_subject_sets/#{@state.set.id}.json" target="_blank">Download Raw Data</a>
          { if @state.set.export_document? && (display_field = @state.set.export_document.export_fields[0])?
              <h2>{display_field.name} {display_field.value}</h2>
            else
              <h2>Record {@state.set.id}</h2>
          }

          <img src={@state.set.subjects[0].location.standard} className="standard-image"/>

          { if @state.tabs.length > 1
              <ul className="tabs">
              { if @state.tabs.indexOf('export-doc') >= 0
                  <li className={ if @state.tab == 'export-doc' then 'active' else '' }><a href="javascript:void(0);" onClick={@showExportDoc}>Best Data</a></li>
              }
              <li className={ if @state.tab == 'assertions' then 'active' else '' }><a href="javascript:void(0);" onClick={@showAssertions}>All Data</a></li>
              <li className={ if @state.tab == 'source-metadata' then 'active' else '' }><a href="javascript:void(0);" onClick={=> @showTab('source-metadata')}>Source Metadata</a></li>
              </ul>
          }

          { if @state.tab == 'export-doc' && @state.set.export_document
              <div>
                <p>These data points represent numerous individual classifications that have been merged and lightly cleaned up to adhere to {@props.project.title}'s data model.</p>

                { for field,i in @state.set.export_document.export_fields
                    if field.assertion_ids
                      assertion = subject = null
                      for s in @state.set.subjects
                        for a in s.assertions
                          if field.assertion_ids.indexOf(a.id) >= 0
                            assertion = a
                            subject = s
                      if assertion && subject
                        <div key={i}>
                          <FinalSubjectAssertion subject={subject} assertion={assertion} project={@props.project} field={field}/>
                        </div>
                }
              </div>
          }

          { if @state.tab == 'assertions'
              <div>
                <p>These data points represent all distinct assertions made upon this {@props.project.term('subject set')} - without cleanup. Each assertion may represent several distinct contributions.</p>
                <ul>
                  { for subject in @state.set.subjects
                      <li key={subject.id}>
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
          }

          { if @state.tab == 'source-metadata'

            <div>
              <p>This metadata was imported alongside the source images at the beginning of the project and may include high res source URIs and processing details.</p>
              
              <dl className="source-metadata">
              { for k,v of @state.set.meta_data
                  <div>
                    <dt>{k.split('_').map( (v) => v.capitalize() ).join(' ')}</dt>
                    { if v.match(/https?:\/\//)
                        <dd><a href={v} target="_blank">{v}</a></dd>
                      else
                        <dd>{v}</dd>
                    }
                  </div>
              }
              </dl>
            </div>
          }
        </div>
      </div>
    </GenericPage>


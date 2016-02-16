React                     = require 'react'
{Navigation}              = require 'react-router'
API                       = require '../lib/api'
Project                   = require 'models/project.coffee'
GenericButton             = require('components/buttons/generic-button')
LoadingIndicator          = require('components/loading-indicator')

module.exports = React.createClass
  displayName: 'FinalSubjectSetBrowser'

  mixins: [Navigation]

  getInitialState:->
    entered_keyword: @props.query.keyword
    selected_field: @props.query.field
    searched_query: {}
    fetching_keyword: null
    current_page: 1
    more_pages: false
    results: []
    project: null

  componentDidMount: ->
    @checkKeyword()

    API.type('projects').get().then (result)=>
      @setState project: new Project(result[0])

  componentWillReceiveProps: (new_props) ->
    @checkKeyword new_props

  checkKeyword: (props = @props) ->
    if props.query.keyword
      @fetch({keyword: props.query.keyword, field: props.query.field})

  fetch: (query, page = 1) ->
    return if ! @isMounted()

    if query.keyword != @state.fetching_keyword || query.field != @state.selected_field

      results = @state.results
      results = [] if @state.searched_query?.keyword != query.keyword
      @setState fetching_keyword: query.keyword, fetching_page: page, results: results, () =>
        per_page = 20
        params =
          keyword: query.keyword
          field: query.field
          per_page: per_page
          page: @state.fetching_page

        API.type('final_subject_sets').get(params).then (sets) =>
          results = @state.results
          offset = (@state.fetching_page-1) * per_page
          for s,i in sets
            results[i + offset] = s
          @setState
            results: results
            searched_query:
              keyword: @props.query.keyword
              field: @props.query.field
            current_page: page
            fetching_page: null
            more_pages: sets?[0]?.getMeta('next_page')
            fetching_keyword: null
 
  handleKeyPress: (e) ->
    if @isMounted()

      if [13].indexOf(e.keyCode) >= 0 # ENTER:
        @search e.target.value

  search: (keyword, search_field) ->
    keyword = @state.entered_keyword # refs.search_input?.getDOMNode().value.trim() unless keyword?
    field = @state.selected_field # @refs.search_field?.getDOMNode().value.trim()

    @transitionTo "final_subject_sets", null, {keyword: keyword, field: field}

  loadMore: ->
    @fetch @state.searched_query, @state.current_page + 1

  handleChange: (e) ->
    @setState entered_keyword: e.target.value

  handleFieldSelect: (e) ->
    @setState selected_field: e.target.value


  renderSearch: ->
    <div>
      <h3>Browse</h3>

      <p>Preview the data by searching by keyword below:</p>
      <form>
        { if @state.project.export_document_specs?[0]?.spec_fields
            <select ref="search_field" value={@state.selected_field} onChange={@handleFieldSelect}>
              <option value="">All Fields</option>
              { for field in @state.project.export_document_specs[0].spec_fields when typeof(field.format)== 'string'
                  <option key={field.name} value={field.name}>{field.name}</option>
              }
            </select>
        }
        <div>
          <input id="data-search" type="text" placeholder="Enter keyword" ref="search_input" value={@state.entered_keyword} onChange={@handleChange} onKeyDown={@handleKeyPress} />
          <button className="standard-button" onClick={@search}>Search</button>
        </div>
      </form>

      { if @state.fetching_keyword && @state.fetching_keyword != @state.searched_query?.keyword
          <LoadingIndicator />
        
        else if @state.searched_query?.keyword && @state.results.length == 0
          <p>No matches yet for "{@state.searched_query.keyword}"</p>

        else if @state.results.length > 0
          <div>
            <p>Found {@state.results[0].getMeta('total')} matches</p>
            <ul className="results">
            { for set in @state.results
                url = "/#/data/exports/#{set.id}?keyword=#{@state.searched_query.keyword}&field=#{@state.searched_query.field}"
                matches = []

                safe_keyword = (w.replace(/\W/g, "\\$&") for w in @state.searched_query.keyword.toLowerCase().replace(/"/g,'').split(' ')).join("|")
                safe_keyword = (c for c in safe_keyword).join ",?"
                regex = new RegExp("(#{safe_keyword})", 'gi')

                # If a specific field searched, always show that:
                if @state.searched_query?.field
                  term = set.search_terms_by_field[@state.searched_query.field]?.join("; ")
                  matches.push(field: @state.searched_query.field, term: term) if term

                # Otherwise show all fields that match
                else
                  for k of set.search_terms_by_field
                    matches.push(field: k, term: v) for v in set.search_terms_by_field[k] when v.match(regex)

                <li key={set.id}>
                  <div className="image">
                    <a href={url}>
                      <img src={set.subjects[0].location.thumbnail} />
                    </a>
                  </div>
                  <div className="matches">
                    { for m,i in matches[0...2]
                        <div key={i} className="match">
                          <a href={url}>
                            <span className="field">{m.field}</span>
                            <span className="term" dangerouslySetInnerHTML={{__html: m.term.truncate(100).replace(regex, "<em>$1</em>")}} />
                          </a>
                        </div>
                    }
                  </div>
                </li>
            }
            </ul>
            { if @state.fetching_keyword && @state.fetching_keyword == @state.searched_query?.keyword
                <LoadingIndicator />

              else if @state.more_pages
                <GenericButton className="load-more" onClick={@loadMore} label="More" />
            }
          </div>
      }
    </div>
    
  renderDownloadCopy: ->
    <div>

      { if ! @state.fetching_keyword && ! @state.searched_query?.keyword
        <div>
          <h3>Download</h3>

          <p>You can download the latest using the button in the upper-right. For help interpretting the data, see <a href="https://github.com/zooniverse/scribeAPI/wiki/Data-Exports#user-content-data-model" target="_blank">Scribe WIKI on Data Exports</a>.</p>

        </div>
      }
    </div>

  render: ->
    return null if ! @state.project?

    <div className="page-content final-subject-set-browser">
      <h2>Data Exports</h2>


      { if ! @state.project.downloadable_data
          <div>
            <h3>Data Exports Not Available</h3>
            <p>Sorry, but public data exports are not enabled for this project yet.</p>
          </div>
          
        else
          <div>
            { if @state.project.latest_export?
                <div>
                  <a className="standard-button json-link" href="/data/latest" target="_blank">Download Latest Raw Data</a> <a className="standard-button json-link" href="/data.atom" target="_blank" title="ATOM Feed of Data Releases"><i className="fa fa-rss-square"></i></a>
                </div>

              else
                <p>Participants have made {@state.project.classification_count.toLocaleString()} contributions to {@state.project.title} to date. This project periodically builds a merged, anonymized snapshot of that data, which can be browsed here.</p>
            }

            { if ! @state.searched_query?.keyword
                <p>Participants have made {@state.project.classification_count.toLocaleString()} contributions to {@state.project.title} to date. This project periodically builds a merged, anonymized dump of that data, which is made public here.</p>
            }

            { @renderSearch() }

            { if ! @state.searched_query?.keyword
                @renderDownloadCopy()
            }

          </div>
        }
      </div>


React                     = require 'react'
{Navigation}              = require 'react-router'
API                       = require '../lib/api'
Project                   = require 'models/project.coffee'
GenericButton             = require('components/buttons/generic-button')

module.exports = React.createClass
  displayName: 'FinalSubjectSetBrowser'

  mixins: [Navigation]

  getInitialState:->
    entered_keyword: @props.query.keyword
    searched_keyword: null
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
      @fetch props.query.keyword

  fetch: (keyword, page = 1) ->
    return if ! @isMounted()

    if keyword != @state.fetching_keyword

      results = @state.results
      results = [] if @state.searched_keyword != keyword
      @setState fetching_keyword: keyword, fetching_page: page, results: results, () =>
        per_page = 20
        params =
          keyword: keyword
          per_page: per_page
          page: @state.fetching_page

        API.type('final_subject_sets').get(params).then (sets) =>
          results = @state.results
          offset = (@state.fetching_page-1) * per_page
          for s,i in sets
            results[i + offset] = s
          @setState
            results: results
            searched_keyword: @props.query.keyword
            current_page:  @state.fetching_page
            fetching_keyword: null
            fetching_page: null
            more_pages: sets?[0]?.getMeta('next_page')
 
  handleKeyPress: (e) ->
    if @isMounted()

      if [13].indexOf(e.keyCode) >= 0 # ENTER:
        @search e.target.value

  search: (keyword) ->
    keyword = @refs.search_input?.getDOMNode().value.trim() unless keyword?

    @transitionTo "final_subject_sets", null, {keyword: keyword}

  loadMore: ->
    @fetch @state.searched_keyword, @state.current_page + 1

  handleChange: (e) ->
    @setState entered_keyword: e.target.value
           
  render: ->
    return null if ! @state.project?

    <div className="page-content final-subject-set-browser">

      { if ! @state.project.downloadable_data
          <div>
            <h3>Data Exports Not Available</h3>
            <p>Sorry, but public data exports are not enabled for this project yet.</p>
          </div>
          
        else
          <div>
            <a className="standard-button json-link" href="/data/latest" target="_blank">Download Latest Raw Data</a>
            <a className="standard-button json-link" href="/data.atom" target="_blank" title="ATOM Feed of Data Releases"><i className="fa fa-rss-square"></i></a>

            <h2>Data Exports</h2>

            { if ! @state.searched_keyword
              <div>
                <h3>Download</h3>

                <p>Participants have made {@state.project.classification_count.toLocaleString()} contributions to {@state.project.title} to date. This project periodically builds a merged, anonymized dump of that data, which is made public here.</p>
                
                <p>You can download the latest using the button in the upper-right. For help interpretting the data, see <a href="https://github.com/zooniverse/scribeAPI/wiki/Data-Exports" target="_blank">Scribe WIKI on Data Exports</a>.</p>

                <h3>Browse</h3>

                <p>Preview the data by searching by keyword below:</p>
              </div>
            }

            <form>
              <input id="data-search" type="text" placeholder="Enter keyword" ref="search-input" value={@state.entered_keyword} onChange={@handleChange} onKeyDown={@handleKeyPress} />
              <input className="standard-button" type="submit" value="Search" onclick={@search} />
            </form>

            { if @state.searched_keyword && @state.results.length == 0
                <p>No matches yet for "{@state.searched_keyword}"</p>

              else if @state.results.length > 0
                <div>
                  <p>Found {@state.results[0].getMeta('total')} matches</p>
                  <ul className="results">
                  { for set in @state.results
                      url = "/#/data/exports/#{set.id}?keyword=#{@state.searched_keyword}"
                      matches = []
                      safe_keyword = (w.replace(/\W/g, "\\$&") for w in @state.searched_keyword.toLowerCase().replace(/"/g,'').split(' ')).join("|")
                      regex = new RegExp("(#{safe_keyword})", 'gi')
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
                  { if @state.more_pages
                      <GenericButton className="load-more" onClick={@loadMore} label="More" />
                  }
                </div>
            }
          </div>
        }
      </div>


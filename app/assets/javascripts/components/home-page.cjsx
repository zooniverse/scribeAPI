
React         = require("react")
GroupBrowser  = require('./group-browser')
NameSearch    = require('./name-search')
{Navigation}  = require 'react-router'


HomePage = React.createClass
  displayName : "HomePage"
  mixins: [Navigation]
  getInitialState: ->
    project: null

  componentDidMount: ->
    return if ! @isMounted()

    if ! @state.project
      API.type('projects').get().then (result)=>
        console.log "got projects"
        project = result[0]
        @setState project: project

  markClick: ->
    @transitionTo 'mark', {}

  transcribeClick: ->
    @transitionTo 'transcribe', {}


  render:->
    <div className="home-page">
      { if @state.project?.home_page_content?

        <div className="page-content">
          <h1>{@state.project?.title}</h1>
          <div dangerouslySetInnerHTML={{ __html: marked(@state.project.home_page_content) }} />

          {
            # Is there a metadata search configured, and should it be on the homepage?
            # TODO If mult metadata_search fields configured, maybe offer a <select> to choose between them
            if @state.project?.metadata_search?.feature_on_homepage
              for field in @state.project.metadata_search.fields
                <div className="metadata-search">
                  <img id="search-icon" src={"assets/searchtool.svg"}/>
                  <NameSearch field={field.field} />
                </div>
          }

          <div className='group-area'>
            <GroupBrowser project={@props.project} />
          </div>
        </div>
      }
    
    </div>

module.exports = HomePage

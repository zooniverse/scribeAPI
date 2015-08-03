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
          <p>Do your part to help transcribe first-hand accounts of New Zealanders from the Australian and New Zealand Army Corps.</p>
          
          <div id="decision-area" >
            <a onClick={@markClick} >Start Marking</a> <span id="fancyor">or</span> <a onClick={@transcribeClick} >Start Transcribing</a>
          </div>
          
          <div id="record-search" >
            <NameSearch />
          </div>
        </div>
      }
    </div>

module.exports = HomePage

React         = require("react")
GroupBrowser  = require('./group-browser')
NameSearch    = require('./name-search')

HomePage = React.createClass
  displayName : "HomePage"

  getInitialState: ->
    project: null

  componentDidMount: ->
    return if ! @isMounted()

    if ! @state.project
      API.type('projects').get().then (result)=>
        console.log "got projects"
        project = result[0]
        @setState project: project

  render:->
    <div className="home-page">
      { if @state.project?.home_page_content?

        <div className="page-content">
          <h1>{@state.project?.title}</h1>
          <div dangerouslySetInnerHTML={{ __html: marked(@state.project.home_page_content) }} />
          <p> Search for a Person </p> 
          <br/>
          <NameSearch />
          <div className='group-area'>
            <GroupBrowser project={@props.project} />
          </div>
        </div>
      }
    </div>

module.exports = HomePage

React = require("react")
GroupBrowser  = require('./group-browser')

HomePage = React.createClass
  displayName : "HomePage"

  getInitialState: ->
    project: null

  componentDidMount: ->
    return if ! @isMounted()

    if ! @state.project
      console.log "fetch projects"
      API.type('projects').get().then (result)=>
        console.log "got projects"
        project = result[0]
        @setState project: project

  render:->
    console.log "render homepage: ", @state.project

    <div className="home-page">

      <div className="page-content">
        <h1>{@state.project?.title}</h1>
        <div dangerouslySetInnerHTML={{__html: @state.project?.home_page_content}} />
      </div>

      { if @props.project?
        <div className='group-area'>
          <GroupBrowser project={@props.project} />
        </div>
      }
    </div>

module.exports = HomePage

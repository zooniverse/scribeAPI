React = require("react")
GroupBrowser  = require('./group-browser')

HomePage = React.createClass
  displayName : "HomePage"

  render:->
    console.log "render homepage"

    <div className="home-page">

      <div className="page-content">
        <h1>{@props.title}</h1>
        <div dangerouslySetInnerHTML={{__html: @props.content}} />
      </div>

      { if @props.project?
        <div className='group-area'>
          <GroupBrowser project={@props.project} />
        </div>
      }
    </div>

module.exports = HomePage

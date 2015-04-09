React = require("react")
GroupBrowser  = require('./group-browser')

HomePage = React.createClass
  displayName : "HomePage"

  render:->
    <div className="home-page">

      <div className="page-content">
        <h1>{@props.title}</h1>
        <div dangerouslySetInnerHTML={{__html: @props.content}} />
      </div>

      <div className='group-area'>
        <GroupBrowser></GroupBrowser>
      </div>
    </div>

module.exports = HomePage

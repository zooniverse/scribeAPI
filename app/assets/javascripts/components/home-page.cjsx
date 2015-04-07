React = require("react")
GroupBrowser  = require('./group-browser')

HomePage = React.createClass
  displayName : "HomePage"

  render:->
    <div className="home-page">
        <div className="page-content" dangerouslySetInnerHTML={{__html: @props.content}} />
        <div className='group-area'>
          <GroupBrowser></GroupBrowser>
        </div>
    </div>

module.exports = HomePage

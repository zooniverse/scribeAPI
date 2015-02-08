React = require("react")

HomePage = React.createClass
  displayName : "HomePage"

  render:->
    <div className="home-page">
        <div className="page-content" dangerouslySetInnerHTML={{__html: @props.content}} />
    </div>

module.exports = HomePage

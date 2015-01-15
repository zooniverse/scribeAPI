React = require("react")

HomePageController = React.createClass
  displayName : "homePageController"

  render:->
    <div className="home-page">
        <div className="page-content" dangerouslySetInnerHTML={{__html: @props.content}} />
    </div>

module.exports = HomePageController

React = require("react")

HomePageController = React.createClass
  displayName : "homePageController"

  render:->
    <div className="home-page">
      <div className="home-page-content">
        <h1> This is the home page </h1>
      </div>
    </div>

module.exports = HomePageController

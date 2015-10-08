React = require("react")
MainHeader                    = require '../partials/main-header'
Footer                        = require '../partials/footer'
API                           = require '../lib/api'
Project                       = require 'models/project.coffee'

{RouteHandler}                = require 'react-router'

window.API = API

App = React.createClass

  getInitialState: ->
    routerRunning:        false

  setTutorialComplete:->
    @setState project: $.extend(project, current_user_tutorial: true)

  render: ->
    project = window.project
    return null if ! project?

    style = {}
    style.backgroundImage = "url(#{project.background})" if project.background?

    <div>
      <div className="readymade-site-background" style={style}>
        <div className="readymade-site-background-effect"></div>
      </div>
      <div className="panoptes-main">

        <MainHeader
          workflows={project.workflows}
          feedbackFormUrl={project.feedback_form_url}
          discussUrl={project.discuss_url}
          blogUrl={project.blog_url}
          pages={project.pages}
          short_title={project.short_title}
          logo={project.logo} />
        <div className="main-content">
          <RouteHandler hash={window.location.hash} project={project} setTutorialComplete={@setTutorialComplete} />
        </div>
        <Footer privacyPolicy={ project.privacy_policy }/>
      </div>
    </div>

module.exports = App

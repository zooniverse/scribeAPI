React = require("react")
MainHeader                    = require '../partials/main-header'
Footer                        = require '../partials/footer'
API                           = require '../lib/api'
Project                       = require 'models/project.coffee'

BrowserWarning                = require './browser-warning'

{RouteHandler}                = require 'react-router'

window.API = API

App = React.createClass
  getInitialState: ->
    routerRunning:        false
    user:                 null
    loginProviders:       []

  componentDidMount: ->
    @fetchUser()


  fetchUser:->
    @setState
      error: null
    request = $.getJSON "/current_user"

    request.done (result)=>
      if result?.data
        @setState
          user: result.data
      else

      if result?.meta?.providers
        @setState loginProviders: result.meta.providers

    request.fail (error)=>
      @setState
        loading:false
        error: "Having trouble logging you in"

  setTutorialComplete: ->
    previously_saved = @state.user?.tutorial_complete?

    # Immediately ammend user object with tutorial_complete flag so that we can hide the Tutorial:
    @setState user: $.extend(@state.user ? {}, tutorial_complete: true)

    # Don't re-save user.tutorial_complete if already saved:
    return if previously_saved

    request = $.post "/tutorial_complete"
    request.fail (error)=>
      console.log "failed to set tutorial value for user"


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
          logo={project.logo}
          menus={project.menus}
          user={@state.user}
          loginProviders={@state.loginProviders}
          onLogout={() => @setState user: null}
        />

        <div className="main-content">
          <BrowserWarning />
          <RouteHandler hash={window.location.hash} project={project} onCloseTutorial={@setTutorialComplete} user={@state.user}/>
        </div>
        <Footer privacyPolicy={ project.privacy_policy } menus={project.menus} partials={project.partials} />
      </div>
    </div>

module.exports = App

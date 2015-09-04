React = require("react")
MainHeader                    = require '../partials/main-header'
API                           = require '../lib/api'
AppRouter                     = require './app-router'
Project                       = require 'models/project.coffee'

{RouteHandler}                = require 'react-router'

window.API = API

App = React.createClass

  getInitialState: ->
    project:              null
    routerRunning:        false

  componentDidMount: ->
    if ! @state.project?
      API.type('projects').get().then (result)=>
        project = new Project(result[0])
        @setState project: project

  setTutorialComplete:->
    @state.project.current_user_tutorial = true
    @setState project: project

  render: ->
    return null if ! @state.project?

    style = {}
    style.backgroundImage = "url(#{@state.project.background})" if @state.project.background?

    <div>
      <div className="readymade-site-background" style={style}>
        <div className="readymade-site-background-effect"></div>
      </div>
      <div className="panoptes-main">

        <MainHeader
          workflows={@state.project.workflows}
          feedbackFormUrl={@state.project.feedback_form_url}
          pages={@state.project.pages}
          short_title={@state.project.short_title}
          logo={@state.project.logo} />

        <div className="main-content">
          <RouteHandler hash={window.location.hash} project={@state.project} setTutorialComplete={@setTutorialComplete} />
        </div>
      </div>
    </div>

module.exports = App

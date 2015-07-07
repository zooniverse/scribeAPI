React = require("react")
Router = require 'react-router'
{Handler, Root, RouteHandler, Route, DefaultRoute, Navigation, Link} = Router
MainHeader                    = require '../partials/main-header'
HomePage                      = require './home-page'
Mark                          = require './mark'
Transcribe                    = require './transcribe'
Verify                        = require './verify'
API                           = require '../lib/api'
GroupPage                     = require './group-page'

window.API = API


Foo = React.createClass
  displayName: 'Foo'
  render: ->
    <div>Foo page</div>

App = React.createClass

  getInitialState: ->
    project: null

  componentDidMount: ->

    API.type('projects').get().then (result)=>

      project = result[0]

      @setState (
        project:           project
        home_page_content: project.home_page_content
        pages:             project.pages
        ), () => @runRoutes()

        # DEBUG CODE
        # , => console.log 'PROJECT: ', @state.project

  runRoutes: ->
    console.log "building routes: ", @state.pages
    console.log "Router: ", Router

    React.render <Router>
      <Route component={App} >
        <Route path="home" component={HomePage} />
      </Route>
    </Router>, document.getElementById("main-content")

    """
    routes =
      <Route name="root" path="/" handler={HomePage}>
        <Route
            key="foooooo"
            path="foo"
            handler={Foo}
            name={"foo"}
          />

        { @state.pages?.map (page, key) =>
            console.log "create route: #{page.name}"
            <Route
              key={key}
              path={page.name}
              handler={@controllerForPage(page)}
              name={page.name}
            />
        }

      </Route>
    """
    """
    router = Router.create
      routes: routes
      location: Router.HashLocation
    """

    # @setState router: router, () =>
     #  @state.router.run () =>
        # console.log "Router: ", Router
        # React.render <RouteHandler />, document.getElementById("main-content")

  # childContextTypes:
   #  router: React.PropTypes.func
    # routeDepth: React.PropTypes.number

  # getChildContext: ->
    # router: @state.router
    # routeDepth: 1

  controllerForPage: (page) ->
    React.createClass
      displayName: "#{page.name}Page"
      render: ->
        console.log "render: ", page
        <div className="page-content">
          <h1>{page.name}</h1>
          <div dangerouslySetInnerHTML={{__html: page.content}} />
        </div>

  shouldComponentUpdate: ->

    console.log "should app update?"
    true

  # TODO: workflow being passed as an object in an array. why?
  render: ->
    return null unless @state.pages? # do nothing until project loads from API
    workflows = @state.project.workflows

    # router = @state.router
    # console.log "router: ", router

    style = {}
    style.backgroundImage = "url(#{@state.project.background})" if @state.project.background?

    <div>
      <div className="readymade-site-background" style={style}>
        <div className="readymade-site-background-effect"></div>
      </div>
      <div className="panoptes-main">

        <div className="main-content" id="main-content">
        </div>
      </div>
    </div>

module.exports = App

window.React = React

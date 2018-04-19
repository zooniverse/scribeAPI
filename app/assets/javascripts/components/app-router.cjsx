React = require("react")
App         = require './app'
Router      = require 'react-router'
{Handler, Root, RouteHandler, Route, DefaultRoute, Redirect, Navigation, Link} = Router

HomePage                      = require './home-page'
Mark                          = require './mark'
Transcribe                    = require './transcribe'
Verify                        = require './verify'

# TODO Group routes currently not implemented
GroupPage                     = require './group-page'
GroupBrowser                  = require './group-browser'
FinalSubjectSetBrowser        = require './final-subject-set-browser'
FinalSubjectSetPage           = require './final-subject-set-page'
FinalSubjectSetDownload       = require './final-subject-set-download'
GenericPage                   = require './generic-page'

Project                       = require 'models/project.coffee'

class AppRouter
  constructor: ->
    API.type('projects').get().then (result)=>
      window.project = new Project(result[0])
      @runRoutes window.project

  runRoutes: (project) ->
    routes =
      <Route name="root" path="/" handler={App}>

        <Redirect from="_=_" to="/" />

        <Route name="home" path="/home" handler={HomePage}/>

        { (w for w in project.workflows when w.name in ['mark','transcribe','verify']).map (workflow, key) =>
            handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            <Route
              key={key}
              path={workflow.name}
              handler={handler}
              name={workflow.name}
            />
        }

        { (w for w, i in project.workflows when w.name in ['mark']).map (workflow, key) =>
            handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            <Route
              key={key}
              path={workflow.name + '/:subject_set_id' + '/:subject_id'}
              handler={handler}
              name={workflow.name + '_specific_subject'}
            />
        }
        { (w for w, i in project.workflows when w.name in ['mark']).map (workflow, key) =>
            handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            <Route
              key={key}
              path={workflow.name + '/:subject_set_id'}
              handler={handler}
              name={workflow.name + '_specific_set'}
            />
        }
        { (w for w, i in project.workflows when w.name in ['transcribe','verify']).map (workflow, key) =>
            handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            <Route
              key={key}
              path={workflow.name + '/:subject_id' }
              handler={handler}
              name={workflow.name + '_specific'}
            />
        }
        { (w for w, i in project.workflows when w.name in ['transcribe']).map (workflow, key) =>
            handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            <Route
              key={key}
              path={workflow.name + '/:workflow_id' + '/:parent_subject_id' }
              handler={handler}
              name={workflow.name + '_entire_page'}
            />
        }


        { # Project-configured pages:
          project.pages?.map (page, key) =>
            <Route
              key={key}
              path={page.key}
              handler={@controllerForPage(page)}
              name={page.name}
            />
        }

        <Route
          path="#{project.data_url_base}/browse"
          handler={FinalSubjectSetBrowser}
          name='final_subject_sets'
        />
        { if project.downloadable_data
          <Route
            path="#{project.data_url_base}/browse/:final_subject_set_id"
            handler={FinalSubjectSetPage}
            name='final_subject_set_page'
          />
        }
        <Route
          path="#{project.data_url_base}/download"
          handler={FinalSubjectSetDownload}
          name='final_subject_sets_download'
        />

        <Route
          path='groups'
          handler={GroupBrowser}
          name='groups'
        />
        <Route
          path='groups/:group_id'
          handler={GroupPage}
          name='group_show'
        />


        <DefaultRoute name="home-default" handler={HomePage} />
      </Route>

    Router.run routes, (Handler, state) ->
      React.render <Handler />, document.body

  controllerForPage: (page) ->
    React.createClass
      displayName: "#{page.name}Page"

      componentWillMount:->
        # pattern = new RegExp('^(field_guide#(.*))')
        # selectedID = pattern.match("#{window.location.hash}")
        # if selectedID
        #   $('.selected-content').removeClass("selected-content")

        #   $("div#" + selectedID).addClass("selected-content"))
        #   $("a#" + selectedID).addClass("selected-content"))

      componentDidMount: ->
        pattern = new RegExp('#/[A-z]*#(.*)')
        selectedID = "#{window.location.hash}".match(pattern)

        if selectedID
          $('.selected-content').removeClass("selected-content")

          $("div#" + selectedID[1]).addClass("selected-content")
          $("a#" + selectedID[1]).addClass("selected-content")

        elms = $(React.findDOMNode(this)).find('a.about-nav')
        elms.on "click", (e) ->
          e.preventDefault()
          $('.selected-content').removeClass("selected-content")
          $(this).addClass("selected-content")

          divId = $(this).attr('href')
          $(divId).addClass("selected-content")

        el = $(React.findDOMNode(this)).find("#accordion")
        el.accordion
          collapsible: true
          active: false
          heightStyle: "content"

      render: ->
        formatted_name = page.name.replace("_", " ")
        base_key = page.key.split('/')[0]
        nav = project.page_navs[base_key]
        <GenericPage key={page.name} title={formatted_name} nav={nav} current_nav={"/#/#{page.key}"} content={page.content} footer={"Last Update: #{moment(page.updated_at, moment.ISO_8601).calendar()}"} />

module.exports = AppRouter
window.React = React

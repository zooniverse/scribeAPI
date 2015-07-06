React = require("react")
{Router,Redirect, Routes, Route, Link} = require 'react-router'
MainHeader                    = require '../partials/main-header'
HomePage                      = require './home-page'
Mark                          = require './mark'
Transcribe                    = require './transcribe'
Verify                        = require './verify'
API                           = require '../lib/api'
GroupPage                     = require './group-page'

window.API = API
App = React.createClass

  getInitialState: ->
    project: null

  componentDidMount: ->

    API.type('projects').get().then (result)=>

      project = result[0]

      @setState project:           project
      @setState home_page_content: project.home_page_content
      @setState pages:             project.pages
        # DEBUG CODE
        # , => console.log 'PROJECT: ', @state.project

  controllerForPage: (page) ->
    React.createClass
      displayName: "#{page.name}Page"
      render: ->
        <div className="page-content">
          <h1>{page.name}</h1>
          <div dangerouslySetInnerHTML={{__html: page.content}} />
        </div>

  # TODO: workflow being passed as an object in an array. why?
  render: ->
    return null unless @state.pages? # do nothing until project loads from API
    workflows = @state.project.workflows

    style = {}
    style.backgroundImage = "url(#{@state.project.background})" if @state.project.background?

    <div>
      <div className="readymade-site-background" style={style}>
        <div className="readymade-site-background-effect"></div>
      </div>
      <div className="panoptes-main">
        <MainHeader workflows={workflows} pages={@state.pages} short_title={@state.project.short_title} />
        <div className="main-content">
          <Routes>
            <Redirect from="_=_" to="/" />
            <Route
              path='/'
              handler={HomePage}
              name="root"
              content={@state.home_page_content}
              project={@state.project}
              title={@state.project.title} />

            { (w for w in workflows when w.name in ['mark','transcribe','verify']).map (workflow, key) =>
                handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
                <Route
                  key={key}
                  path={'/' + workflow.name}
                  handler={handler}
                  name={workflow.name}
                  workflow={workflow} />
            }

            { (w for w, i in workflows when w.name in ['mark']).map (workflow, key) =>
                handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
                <Route
                  key={key}
                  path={'/' + workflow.name + '/:subject_set_id' + '/:selected_subject_id'}
                  handler={handler}
                  name={workflow.name + '_specific'}
                  workflow={workflow} />
            }
            { (w for w, i in workflows when w.name in ['transcribe','verify']).map (workflow, key) =>
                handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
                <Route
                  key={key}
                  path={'/' + workflow.name + '/:subject_id' }
                  handler={handler}
                  name={workflow.name + '_specific'}
                  workflow={workflow} />
            }

            { @state.pages?.map (page, key) =>
                <Route
                  key={key}
                  path={'/'+page.name}
                  handler={@controllerForPage(page)}
                  name={page.name}
                />
            }

          </Routes>
        </div>
      </div>
    </div>
module.exports = App

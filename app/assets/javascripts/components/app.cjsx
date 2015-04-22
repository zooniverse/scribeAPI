React = require("react")
{Router,Redirect, Routes, Route, Link} = require 'react-router'
MainHeader                    = require '../partials/main-header'
HomePage                      = require './home-page'
Mark                          = require './mark'
Transcribe                    = require './transcribe'
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

    style =
      backgroundImage: "url(#{@state.project.background})"

    <div>
      <div className="readymade-site-background" style={style}>
        <div className="readymade-site-background-effect"></div>
      </div>
      <div className="panoptes-main">
        <MainHeader pages={@state.pages} short_title={@state.project.short_title} />
        <div className="main-content">
          <Routes>
            <Redirect from="_=_" to="/" />
            <Route
              path='/'
              handler={HomePage}
              name="root"
              content={@state.home_page_content}
              title={@state.project.title} />
            <Route
              path='/mark'
              handler={Mark}
              name='mark'
              workflow={(workflow for workflow in workflows when workflow.name is 'mark')[0]} />
            <Route
              path='/mark/:subject_set_id'
              handler={Mark}
              name='mark_specific'
              workflow={(workflow for workflow in workflows when workflow.name is 'mark')[0]} />
            <Route
              path='/transcribe'
              handler={Transcribe}
              name='transcribe_specific'
              workflow={(workflow for workflow in workflows when workflow.name is 'transcribe')[0]} />
            <Route
              path='/transcribe/:subject_set_id'
              handler={Transcribe}
              name='transcribe'
              workflow={(workflow for workflow in workflows when workflow.name is 'transcribe')[0]} />
            <Route
              path='/groups/:group_id'
              handler={GroupPage}
              name="group"
            />

            { @state.pages?.map (page, key) =>
                <Route
                  path={'/'+page.name}
                  handler={@controllerForPage(page)}
                  name={page.name} key={key} />
            }

          </Routes>
        </div>
      </div>
    </div>
module.exports = App

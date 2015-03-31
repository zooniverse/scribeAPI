React = require("react")
{Router,Redirect, Routes, Route, Link} = require 'react-router'
MainHeader                    = require '../partials/main-header'
HomePage                      = require './home-page'
Mark                          = require './mark'
Transcribe                    = require './transcribe'

DynamicRouter = React.createClass

  getInitialState: ->
    project: null

  componentDidMount: ->
    $.getJSON '/projects', (result) =>
      @setState project:           result.project
      @setState home_page_content: result.project.home_page_content
      @setState pages:             result.project.pages
        # DEBUG CODE
        # , => console.log 'PROJECT: ', @state.project

  controllerForPage: (page) ->
    React.createClass
      displayName: "#{page.name}Page"
      render: ->
        <div dangerouslySetInnerHTML={{__html: page.content}} />

  # TODO: workflow being passed as an object in an array. why?
  render: ->
    return null unless @state.pages? # do nothing until project loads from API
    workflows = @state.project.workflows

    <div className="panoptes-main">
      <MainHeader pages={@state.pages} />
      <div className="main-content">
        <Routes>
          <Redirect from="_=_" to="/" />
          <Route
            path='/'
            handler={HomePage}
            name="root"
            content={@state.home_page_content} />
          <Route
            path='/mark'
            handler={Mark}
            name='mark'
            workflow={(workflow for workflow in workflows when workflow.name is 'mark')[0]} />
          <Route
            path='/transcribe'
            handler={Transcribe}
            name='transcribe'
            workflow={(workflow for workflow in workflows when workflow.name is 'transcribe')[0]} />

          { @state.pages?.map (page, key) =>
              <Route
                path={'/'+page.name}
                handler={@controllerForPage(page)}
                name={page.name} key={key} />
          }

        </Routes>
      </div>
    </div>

module.exports = DynamicRouter

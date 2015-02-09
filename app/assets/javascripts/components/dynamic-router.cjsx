React = require("react")
{Router, Routes, Route, Link} = require 'react-router'
MainHeader                    = require '../partials/main-header'
HomePage                      = require './home-page'
Mark                          = require './mark'
Transcribe                    = require './transcribe'

DynamicRouter = React.createClass

  getInitialState: ->
    project: null
    markWorkflow: null
    transcribeWorkflow: null
    
  componentDidMount: ->
    $.getJSON '/project', (result) => 
      @setState project:           result
      @setState home_page_content: @state.project.home_page_content 
      @setState pages:             @state.project.pages
      
      for workflow in @state.project.workflows
        @setState markWorkflow:       workflow if workflow.key is 'mark'
        @setState transcribeWorkflow: workflow if workflow.key is 'transcribe'

  controllerForPage: (page) ->
    React.createClass
      displayName: "#{page.name}Page"
      render: ->
        <div dangerouslySetInnerHTML={{__html: page.content}} />

  render: ->
    # do nothing until project loads from API
    return null unless @state.pages?

    <div className="panoptes-main">
      <MainHeader pages={@state.pages} />
      <div className="main-content">
        <Routes>
          <Route 
            path='/' 
            handler={HomePage} 
            name="root" 
            content={@state.home_page_content} />
          <Route 
            path='/mark' 
            handler={Mark} 
            name='mark'
            workflow={@state.markWorkflow} />
          <Route 
            path='/transcribe' 
            handler={Transcribe} 
            name='transcribe'
            workflow={@state.transcribeWorkflow} />

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

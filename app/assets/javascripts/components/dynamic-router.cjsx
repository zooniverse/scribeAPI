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
        switch workflow.key
          when 'mark'       then @setState markWorkflow: workflow
          when 'transcribe' then @setState transcribeWorkflow: workflow
       
  controllerForPage: (page) ->
    React.createClass
      displayName: "#{page.name}Page"
      render: ->
        <div dangerouslySetInnerHTML={{__html: page.content}} />

  render: ->
    return null unless @state.pages? # do nothing until project loads from API

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
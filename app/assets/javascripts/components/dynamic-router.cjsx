React = require("react")
{Router, Routes, Route, Link} = require 'react-router'
MainHeader                    = require '../partials/main-header'
HomePage                      = require './home-page'
Mark                          = require './mark'
Transcribe                    = require './transcribe'

DynamicRouter = React.createClass

  getInitialState: ->
    project: null
    
  componentDidMount: ->
    $.getJSON '/project', (result) => 
      @setState project:           result
      @setState home_page_content: result.home_page_content 
      @setState pages:             result.pages
      
      for workflow in @state.project.workflows
        @setState mark_tasks: workflow.tasks if workflow.key is 'mark'
        @setState transcribe_tasks: workflow.tasks if workflow.key is 'transcribe'
  controllerForPage: (page) ->
    React.createClass
      displayName: "#{page.name}Page"
      render: ->
        <div dangerouslySetInnerHTML={{__html: page.content}} />

  render: ->
    # do nothing until project loads from API
    # return null # just for now
    return null if @state.project is null or @state.mark_tasks is null or @state.transcribe_tasks is null
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
            workflow={(workflow for workflow in workflows when workflow.key is 'mark')[0]} />
          <Route 
            path='/transcribe' 
            handler={Transcribe} 
            name='transcribe'
            workflow={(workflow for workflow in workflows when workflow.key is 'transcribe')[0]} />

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
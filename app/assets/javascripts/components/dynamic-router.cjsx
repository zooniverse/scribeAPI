React = require("react")
{Router, Routes, Route, Link} = require 'react-router'

MainHeader         = require('../partials/main-header')
HomePageController = require("./home-page-controller")
ImageSubjectViewer_mark = require('./image-subject-viewer-mark')
ImageSubjectViewer_transcribe = require('./image-subject-viewer-transcribe')

pages = [
  {
    name:    'info', 
    content: 'I am a content thingie'
  },
  {
    name:    'science', 
    content: 'I am science'
  }
]

DynamicRouter = React.createClass

  getInitialState: ->
    transcribe_workflow: null

  componentDidMount: ->
    $.getJSON '/workflows/transcribe', (result) => 
      # console.log 'SETTING WORKFLOW: ', result
      @setState transcribe_workflow: result

  controllerForPage:(p)->
    React.createClass
      displayname: "#{p.name}_page"
      render:->
        <div>
          {p.content}
        </div>

  render:->
    # do nothing until workflow loaded
    return null if @state.transcribe_workflow is null
      
    <div className="panoptes-main">
      <MainHeader />
      <div className="main-content">
        <Routes>
          <Route path='/'           handler={HomePageController}            name="root" />
          <Route path='/mark'       handler={ImageSubjectViewer_mark}       name='mark' />
          <Route path='/transcribe' handler={ImageSubjectViewer_transcribe} name='transcribe' tasks={@state.transcribe_workflow.tasks}  
          />

          {pages.map (p, key)=>
            <Route path="/#{p.name}" handler={@controllerForPage(p)} name={p.name} key={key} />
          }
        </Routes>
      </div>
    </div>
module.exports = DynamicRouter

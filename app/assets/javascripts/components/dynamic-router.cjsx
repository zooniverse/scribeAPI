React = require("react")
{Router, Routes, Route, Link} = require 'react-router'

MainHeader         = require('../partials/main-header')
HomePageController = require("./home-page-controller")
ImageSubjectViewer_mark = require('./image-subject-viewer-mark')
ImageSubjectViewer_transcribe = require('./image-subject-viewer-transcribe')

DynamicRouter = React.createClass

  componentWillReceiveProps: ->
    console.log 'Psdfsdfdsf: ', @props.project.workflow.transcribe
    null

  controllerForPage:(p)->
    React.createClass
      displayname: "#{p.name}_page"
      render:->
        <div>
          {p.content}
        </div>

  render:->
    # console.log @, @state
    <div className="panoptes-main">
      <MainHeader />
      <div className="main-content">
        <Routes>
          <Route path='/' handler={HomePageController} name="root" />
          <Route path='/mark' handler={ImageSubjectViewer_mark} name='mark' task='mark' />
          <Route 
            path='/transcribe' 
            handler={ImageSubjectViewer_transcribe} 
            name='transcribe' 
            task='transcribe'
            transcribeSteps={@props.project.workflow.transcribe.steps}  
          />

          {@props.project.pages.map (p, key)=>
            <Route path="/#{p.name}" handler={@controllerForPage(p)} name={p.name} key={key} />
          }
        </Routes>
      </div>
    </div>
module.exports = DynamicRouter

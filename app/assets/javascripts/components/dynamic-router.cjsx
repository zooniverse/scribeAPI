React = require("react")
{Router, Routes, Route, Link} = require 'react-router'

HomePageController = require("./home-page-controller")
ImageSubjectViewer = require('./image-subject-viewer')

DynamicRouter = React.createClass
  controllerForPage:(p)->
    React.createClass
      displayname: "#{p.name}_page"
      render:->
        <div>
          {p.content}
        </div>

  render:->
    # console.log @, @state
    <Routes>
      <Route path='/' handler={HomePageController} name="root" />
      <Route path='/transcribe' handler={ImageSubjectViewer} name='transcribe' />

      {@props.pages.map (p)=>
        <Route path="/#{p.name}" handler={@controllerForPage(p)} name={p.name} />
      }
    </Routes>

module.exports = DynamicRouter

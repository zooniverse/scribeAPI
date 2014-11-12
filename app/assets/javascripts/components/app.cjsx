# @cjsx React.DOM

# React = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
# require components here:

DynamicRouter      = require './dynamic-router'

pages = [{name: "info", content: "I am a content thingie"},{name: "science", content: "I am science"}]

App = React.createClass
  displayname: 'app'

  render: ->
    <div>
      <div className="readymade-site-background">
        <div className="readymade-site-background-effect"></div>
      </div>
      <DynamicRouter pages= {pages} />
    </div>
module.exports = App

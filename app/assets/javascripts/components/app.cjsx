# @cjsx React.DOM

# React = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
# require components here:

DynamicRouter      = require './dynamic-router'

pages = [{name: "info", content: "I am a content thingie"},{name: "science", content: "I am science"}]

App = React.createClass
  displayname: 'app'

  render: ->
    <div className="sample-component">
      <h1>Scribe 2.0</h1>
      <p>For all your transcription needs</p>
      <DynamicRouter pages= {pages} />
    </div>

module.exports = App

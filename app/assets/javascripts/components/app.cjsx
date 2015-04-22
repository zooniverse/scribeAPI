# @cjsx React.DOM

React = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
DynamicRouter = require './dynamic-router'

# IMPORTANT!
window.React = React

App = React.createClass
  displayname: 'app'


  render: ->
    console.log 'PROPS: ', @props
    <div>
      <div className="readymade-site-background">
        <div className="readymade-site-background-effect"></div>
      </div>
      <DynamicRouter />
    </div>

module.exports = App

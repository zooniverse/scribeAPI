# @cjsx React.DOM

React = require 'react'
Login = require '../components/login'
# LoadingIndicator = require '../components/loading-indicator'
# MainNav = require './main-nav'
# AccountBar = require './account-bar'
# LoginBar = require './login-bar'
# PromiseToSetState = require '../lib/promise-to-set-state'
# auth = require '../api/auth'

module.exports = React.createClass
  displayName: 'MainHeader'

  # mixins: [PromiseToSetState]

  # componentDidMount: ->
  #   @handleAuthChange()
  #   auth.listen @handleAuthChange

  # componentWillUnmount: ->
  #   auth.stopListening @handleAuthChange

  # handleAuthChange: ->
  #   @promiseToSetState user: auth.checkCurrent()

  render: ->
    <header classNameim="main-header">

      <nav className="main-nav main-header-group">
        <a href="/" root={true} className="main-header-item logo">{@props.short_title}</a>

        { (w for w in @props.workflows when w.name in ['mark','transcribe','verify']).map (workflow) =>
          title = workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
          <a href="/#/#{workflow.name}" className="main-header-item">{title}</a>
        }

        { @props.pages.map (page, key) =>
            <a href={'/#/'+page.name} className="main-header-item" key={key}>{page.name}</a>
        }
        <Login></Login>
      </nav>

      <div className="main-header-group"></div>
    </header>

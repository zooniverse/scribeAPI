# @cjsx React.DOM

React = require 'react'
# LoadingIndicator = require '../components/loading-indicator'
MainNav = require './main-nav'
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
      <MainNav />
      <div className="main-header-group"></div>
    </header>

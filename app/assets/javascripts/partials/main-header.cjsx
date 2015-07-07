React = require("react")
{Link} = require 'react-router'
Router = require 'react-router'
{Navigation, Link} = Router
Login = require '../components/login'

module.exports = React.createClass
  displayName: 'MainHeader'

  mixins: [ Navigation ]

  # mixins: [PromiseToSetState]

  # componentDidMount: ->
  #   @handleAuthChange()
  #   auth.listen @handleAuthChange

  # componentWillUnmount: ->
  #   auth.stopListening @handleAuthChange

  # handleAuthChange: ->
  #   @promiseToSetState user: auth.checkCurrent()

  render: ->
    console.log "rendering header"
    <header classNameim="main-header">

      { current_path = window.location.href.replace /^.*\/#\//, '' }
      <nav className="main-nav main-header-group">
        <a href="/" root={true} className="main-header-item logo">{@props.short_title}</a>

        {
          workflow_names = ['transcribe','mark','verify']
          workflows = (w for w in @props.workflows when w.name in workflow_names)
          workflows = workflows.sort (w1, w2) -> if w1.order > w2.order then 1 else -1
          workflows.map (workflow, key) =>
            title = workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            selected = current_path == workflow.name
            # <a key={key} href="/#/#{workflow.name}" className="main-header-item#{ if selected then ' selected' else '' }">{title}</a>
            <Link key={key} to="/#{workflow.name}" activeClassName="selected" className="main-header-item">{title}</Link>
        }

        { @props.pages.map (page, key) =>
            <Link key={key} to="/#{page.name}" activeClassName="selected" className="main-header-item">{page.name}</Link>
        }
        <Login></Login>
      </nav>

      <div className="main-header-group"></div>
    </header>

React = require("react")
{Link} = require 'react-router'
Router = require 'react-router'
# {Navigation, Link} = Router
Login = require '../components/login'

module.exports = React.createClass
  displayName: 'MainHeader'

  # mixins: [ Navigation ]

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
        <Link to="/" activeClassName="selected" className="main-header-item logo">
          {
            unless @props.logo?
              @props.short_title
            else
              <img src="logo.svg"/>
          }
        </Link>

        {
          # Workflows tabs:
          workflow_names = ['transcribe','mark','verify']
          workflows = (w for w in @props.workflows when w.name in workflow_names)
          workflows = workflows.sort (w1, w2) -> if w1.order > w2.order then 1 else -1
          workflows.map (workflow, key) =>
            title = workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            <Link key={key} to="/#{workflow.name}" activeClassName="selected" className="main-header-item">{title}</Link>
        }
        { # Page tabs:
          @props.pages?.map (page, key) =>
            <Link key={key} to="/#{page.name.toLowerCase()}" activeClassName="selected" className="main-header-item">{page.name}</Link>
        }

        { # include feedback tab if defined
          showFeedbackTab = false
          if @props.feedbackFormUrl? and showFeedbackTab
            <a className="main-header-item" href={@props.feedbackFormUrl}>Feedback</a>
        }
        <Login />

      </nav>

    </header>

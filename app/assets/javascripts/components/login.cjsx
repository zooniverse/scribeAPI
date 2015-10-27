React = require 'react'


Login = React.createClass
  displayName : "Login"

  getInitialState:->
    error: null

  getDefaultProps: ->
    user: null
    loginProviders: []

  render:->
    <div className='login'>
      {@renderLoggedIn() if @props.user?.name? && ! @props.user.guest }
      {@renderLoggedInAsGuest() if @props.user && @props.user.guest }
      {@renderLoginOptions("Log In:","login-container") if !@props.user }
    </div>

  signOut:(e)->
    e.preventDefault()

    request = $.ajax
      url: '/users/sign_out'
      method: 'delete'
      dataType: "json"

    request.done =>
      @setState
        user: null

    request.error (request,error)=>
      @setState
        error : "Could not log out"


  renderLoggedInAsGuest: ->
    <span >
      { @renderLoginOptions('Log in to save your work:',"login-container") }
    </span>

  renderLoggedIn:->
    <span className={"login-container"}>
      { if @props.user.avatar
          <img src="#{@props.user.avatar}" />
      }
      <span className="label">Hello {@props.user.name} </span><a className="logout" onClick={@signOut} >Logout</a>
    </span>


  renderLoginOptions: (label,classNames) ->
    links = @props.loginProviders.map (link) ->
      icon_id = if link.id == 'zooniverse' then 'dot-circle-o' else link.id
      <a key="login-link-#{link.id}" href={link.path} title="Log in using #{link.name}"><i className="fa fa-#{icon_id} fa-2" /></a>

    <span className={classNames}>
      <span className="label">{ label || "Log In:" }</span>
      <div className='options'>
        { links }
      </div>
    </span>


module.exports = Login

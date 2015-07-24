React = require 'react'


Login = React.createClass
  displayName : "Login"

  componentDidMount:->
    @fetchUser()

  getInitialState:->
    user: null
    loading: false
    error: null
    providers: []

  fetchUser:->
    @setState
      loading: true
      error: null
    request = $.getJSON "/current_user"

    request.done (result)=>
      if result?.data
        @setState
          user: result.data
          loading: false
      else
        @setState
          loading: false

      if result?.meta?.providers
        @setState providers: result.meta.providers

    request.fail (error)=>
      @setState
        loading:false
        error: "Having trouble logging you in"

  render:->
    <div className='login'>
      {@renderLoggedIn() if @state.user && ! @state.user.guest }
      {@renderLoggedInAsGuest() if @state.user && @state.user.guest }
      {@renderLoginOptions() if !@state.user }
      {if @state.loading
        <p>Loading ...</p>
      }
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
    <span>
      <span className="guest-hello">Hello Guest!</span>
      { @renderLoginOptions('Log in to save your work:') }
    </span>

  renderLoggedIn:->
    <p>
      { if @state.user.avatar
          <img src="#{@state.user.avatar}" />
      }
      Hello {@state.user.name} <a className="logout" onClick={@signOut} >Logout</a>
    </p>


  renderLoginOptions: (label) ->
    links = []
    if @state.providers.indexOf('facebook') >= 0
      links.push <a key="login-link-fb" href='/users/auth/facebook' title="Log in using Facebook"><i className="fa fa-facebook fa-2" /></a>
    if @state.providers.indexOf('google') >= 0
      links.push <a key="login-link-google" href='/users/auth/google_oauth2' title="Log in using Google+"><i className="fa fa-google-plus fa-2" /></a>
    if @state.providers.indexOf('zooniverse') >= 0
      links.push <a key="login-link-zoonivers" href='/users/auth/zooniverse' title="Log in using Zooniverse"><i className="fa fa-dot-circle-o fa-2" /></a>

    <span>
      { label || "Log In:" }
      <div className='options'>
        { links }
      </div>
    </span>


module.exports = Login

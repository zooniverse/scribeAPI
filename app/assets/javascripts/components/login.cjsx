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
      <span className="label guest-hello">Hello Guest!</span>
      { @renderLoginOptions('Log in to save your work:') }
    </span>

  renderLoggedIn:->
    <p>
      { if @state.user.avatar
          <img src="#{@state.user.avatar}" />
      }
      <span className="label">Hello {@state.user.name} </span><a className="logout" onClick={@signOut} >Logout</a>
    </p>


  renderLoginOptions: (label) ->
    links = @state.providers.map (link) ->
      icon_id = if link.id == 'zooniverse' then 'dot-circle-o' else link.id
      <a key="login-link-#{link.id}" href={link.path} title="Log in using #{link.name}"><i className="fa fa-#{icon_id} fa-2" /></a>

    <span>
      <span className="label">{ label || "Log In:" }</span>
      <div className='options'>
        { links }
      </div>
    </span>


module.exports = Login

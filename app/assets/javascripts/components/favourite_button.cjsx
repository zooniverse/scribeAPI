# @cjsx React.DOM

React = require 'react'


# IMPORTANT!
window.React = React

FavouriteButton = React.createClass
  displayname: 'FavouriteButton'

  getInitialState:=>
    favourite: this.props.subject.user_favourite
    loading: false

  add_favourite:(e)->
    e.preventDefault()
    console.log @, @setState, this

    @setState
      loading: true

    $.post "/subjects/#{this.props.subject.id}/favourite", =>
      @setState
        loading:false
        favourite: true


  remove_favourite: (e)->
    e.preventDefault()
    $.post "/subjects/#{this.props.subject.id}/unfavourite", =>
      @setState
        loading:false
        favourite: false

  render: ->
    if this.state.loading
      <a className='favourite_button'>Loading</a>
    else if this.state.favourite
      <a herf='#' onClick={@remove_favourite} class='favourite_button'>Unfavourite</a>
    else
      <a href='#' onClick={@add_favourite} class='favourite_button'>Favourite</a>


module.exports = FavouriteButton

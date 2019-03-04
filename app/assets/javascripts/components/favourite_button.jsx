var _this = this

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS208: Avoid top-level this
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */


import React from 'react'

// IMPORTANT!
window.React = React

import createReactClass from 'create-react-class'
const FavouriteButton = createReactClass({
  displayname: 'FavouriteButton',

  getInitialState: () => {
    return {
      favourite: _this.props.subject.user_favourite,
      loading: false
    }
  },

  add_favourite(e) {
    e.preventDefault()

    this.setState({
      loading: true
    })

    return $.post(`/subjects/${this.props.subject.id}/favourite`, () => {
      return this.setState({
        loading: false,
        favourite: true
      })
    })
  },

  remove_favourite(e) {
    e.preventDefault()
    return $.post(`/subjects/${this.props.subject.id}/unfavourite`, () => {
      return this.setState({
        loading: false,
        favourite: false
      })
    })
  },

  render() {
    if (this.state.loading) {
      return <a className="favourite_button">Loading</a>
    } else if (this.state.favourite) {
      return (
        <a
          herf="#"
          onClick={this.remove_favourite}
          className="favourite_button"
        >
          Unfavourite
        </a>
      )
    } else {
      return (
        <a href="#" onClick={this.add_favourite} className="favourite_button">
          Favourite
        </a>
      )
    }
  }
})

export default FavouriteButton

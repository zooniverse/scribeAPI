# @cjsx React.DOM

React                         = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
LoadingIndicator              = require './loading-indicator'
ActionButton                  = require './action-button'
DiscourseConnector            = require './forum-connectors/discourse-connector'


module.exports = React.createClass
  displayName: 'ForumSubjectWidget'
  resizing: false

  getInitialState: ->

    subject_set: @props.subject_set
    project: @props.project
    posts: {}
    
  componentDidMount: ->
    @connector = null
    if @state.project.forum?.type == 'discourse'
      @connector = new DiscourseConnector @state.project.forum

    if @connector?
      @setState
        create_url: @connector.create_url()
      @fetchPosts 'subject_set', @state.subject_set.id
      # TODO: fetch posts for group id too?

  fetchPosts: (type, id) ->
    @connector.fetchPosts type, id, (posts) =>
      @setState
        posts: posts

  handleSearchFormSubmit: (e) ->
    e.preventDefault()
    term = @refs.search_term?.getDOMNode().value.trim()
    url = @connector.search_url(term)
    window.open url, '_blank'

  render: ->
    subject_posts = @state.posts['subject_set'] ? []

    <div className="forum-subject-widget">
      <form onSubmit={@handleSearchFormSubmit} method='get' action='javascript:void(0);'><input type="text" ref="search_term" placeholder="Search forum"/></form>
      <h2>Discuss</h2>
      { if subject_posts.length > 0
        <ul>
        { for post in @state.posts['subject_set']
          <li><a target="_blank" href={post.url}>{post.title}</a> (Updated {post.updated_at})</li>
        }
        </ul>
      }
      <a target="_blank" href={@state.create_url}>Start a discussion about this subject set</a>
    </div>


window.React = React

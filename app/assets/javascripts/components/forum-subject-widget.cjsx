# @cjsx React.DOM

React                         = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
LoadingIndicator              = require './loading-indicator'
ForumConnectors               = require './forum-connectors'

module.exports = React.createClass
  displayName: 'ForumSubjectWidget'
  resizing: false

  getDefaultProps: ->
    project:        null
    subject_set:    null
    subject:        null

  propTypes:
    project: React.PropTypes.object

  getInitialState: ->
    connector:      null
    posts:          {}

  # componentDidMount: ->
  componentWillReceiveProps: (new_props) ->

    project = new_props.project # result[0]

    if project.forum?.type?
      if ! ForumConnectors[project.forum?.type]?
        console.warn "Unsupported forum type. No connector defined for #{project.forum.type}"
      else
        connector = new ForumConnectors[project.forum.type] project.forum, project

    if connector?
      @setState connector: connector, () =>
        @fetchPosts 'subject', new_props.subject.id

  fetchPosts: (type, id) ->
    @setState loading: true, () =>
      @state.connector.fetchPosts type, id, (posts) =>
        @setState loading: false
        console.log 'FETCHED posts: ', posts
        @setState
          posts: posts

  handleSearchFormSubmit: (e) ->
    e.preventDefault()
    term = @refs.search_term?.getDOMNode().value.trim()
    url = @state.connector.search_url(term)
    window.open url, '_blank'

  render: ->
    return null if ! @state.connector?
    create_url = @state.connector.create_url @props.subject
    search_enabled = @state.connector.search_url()?

    subject_posts = @state.posts.subject ? ( @state.posts.subject_set ? [] )

    <div className="forum-subject-widget">
      { if search_enabled
          <form onSubmit={@handleSearchFormSubmit} method='get' action='javascript:void(0);'><input type="text" ref="search_term" placeholder="Search forum"/></form>
      }
      <h2>Discuss</h2>

      { if search_enabled and subject_posts.length > 0
        <ul>
        { for post in subject_posts
          <li><a target="_blank" href={post.url}>{post.title}</a> (Updated {post.updated_at})</li>
        }
        </ul>
      }

      { if create_url?
          <p><a target="_blank" href={create_url}>Start a discussion about this {@props.project.term('subject set')}</a></p>
        else
          <p><a>Oops! Disscussions have not been set up for this {@props.project.term('subject set')}.</a></p>
      }
    </div>


window.React = React

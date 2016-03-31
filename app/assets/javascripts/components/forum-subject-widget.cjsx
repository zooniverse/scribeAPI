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
    fetch_status:   {}

  componentWillReceiveProps: (new_props) ->

    project = new_props.project # result[0]

    if project.forum?.type?
      if ! ForumConnectors[project.forum?.type]?
        console.warn "Unsupported forum type. No connector defined for #{project.forum.type}"
      else
        connector = new ForumConnectors[project.forum.type] project.forum, project

    if connector?
      @setState connector: connector, () =>
        @fetchPosts 'subject', new_props.subject.id if new_props.subject?

  fetchPosts: (type, id) ->
    # If we've already fetched or are fetching posts for this type & id, abort
    return if @state.fetch_status["#{type}.#{id}"]?

    # For duration of fetch, status of this fetch is 'fetching'
    @setState
      fetch_status: $.extend(@state.fetch_status, {"#{type}.#{id}": 'fetching'})
      loading: true, () =>
        @state.connector.fetchPosts type, id, (posts) =>
          @setState loading: false

          # Save posts to state as well as setting fetch_status for this type&id to 'fetched'
          @setState
            posts: posts
            fetch_status: $.extend(@state.fetch_status, {"#{type}.#{id}": 'fetched'})

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

      { if @state.loading and search_enabled
          <span>Searching for discussions about this {@props.project.term('subject')}...</span>
        else if subject_posts.length > 0
          <span>
            Discussion about this {@props.project.term('subject')}:
            <ul>
            { for post,i in subject_posts
              <li key={i}>
                "<a target="_blank" href={post.url}>{post.excerpt.truncate 70}</a>"
                <br />&ndash; {post.author}, {moment(post.updated_at).fromNow()}
              </li>
            }
            </ul>
          </span>
      }

      { if create_url?
          <a target="_blank" className="forum-link" href={create_url}> Discuss this {@props.project.term('subject set')}.</a>
        else
          <p>Oops! Disscussions have not been set up for this {@props.project.term('subject set')}.</p>
      }

    </div>
window.React = React

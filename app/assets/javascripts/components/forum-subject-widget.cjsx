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

  componentDidMount: ->
    API.type('projects').get().then (result)=>
      project = result[0]

      if project.forum?.type?
        if ! ForumConnectors[project.forum?.type]?
          console.warn "Unsupported forum type. No connector defined for #{project.forum.type}"
        else
          connector = new ForumConnectors[project.forum.type] project.forum

      if connector?
        @setState connector: connector, () =>
          if @props.subject_set?
            @fetchPosts 'subject_set', @props.subject_set.id
          else if @props.subject?
            @fetchPosts 'subject', @props.subject.id

  fetchPosts: (type, id) ->
    @state.connector.fetchPosts type, id, (posts) =>
      @setState
        posts: posts

  handleSearchFormSubmit: (e) ->
    e.preventDefault()
    term = @refs.search_term?.getDOMNode().value.trim()
    url = @state.connector.search_url(term)
    window.open url, '_blank'

  render: ->
    return null if ! @state.connector?

    create_url = @state.connector.create_url(@props) # needed create_url to have access to props. better way to do this? -STI
    subject_posts = @state.posts.subject ? ( @state.posts.subject_set ? [] )

    <div className="forum-subject-widget">
      <form onSubmit={@handleSearchFormSubmit} method='get' action='javascript:void(0);'><input type="text" ref="search_term" placeholder="Search forum"/></form>
      { if subject_posts.length > 0
        <ul>
        { for post in subject_posts
          <li><a target="_blank" href={post.url}>{post.title}</a> (Updated {post.updated_at})</li>
        }
        </ul>
      }
      <p><a target="_blank" href={create_url}>Start a discussion about this {@props.project.term('subject set')}</a></p>
    </div>


window.React = React

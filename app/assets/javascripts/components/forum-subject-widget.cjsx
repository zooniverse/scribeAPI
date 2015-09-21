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
        # @fetchPosts [new_props.subject_set.id], (posts) =>
        @fetchPosts 'subject', new_props.subject.id # , (posts) =>
          # @setState posts: posts

        """
        return

        if @props.subject_set?
          @fetchPosts 'subject_set', @props.subject_set.id
        else if @props.subject?
          @fetchPosts 'subject', @props.subject.id
        """

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
    subject_posts = @state.posts.subject ? ( @state.posts.subject_set ? [] )

    <div className="forum-subject-widget">
      <form onSubmit={@handleSearchFormSubmit} method='get' action='javascript:void(0);'><input type="text" ref="search_term" placeholder="Search forum"/></form>
      <h2>Discuss</h2>
      { if @state.loading
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
      <a target="_blank" href={create_url}>Start a { if subject_posts.length > 0 then 'new' else '' } discussion about this {@props.project.term('subject set')}</a>
    </div>


window.React = React

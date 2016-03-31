# @cjsx React.DOM

React = require 'react'

module.exports =

  class TalkConnector
    constructor: (@options) ->

    # this method doesn't yet do anytying
    fetchPosts: (type, id, callback) ->
      null
      # url = '/proxy/forum'
      # url += '/search.json?search=' + id
      # $.ajax
      #   url: url
      #   dataType: "json"
      #   success: ((resp) =>
      #
      #     posts = resp.topic_list?.topics ? []
      #     base_url = @options.base_url
      #     posts = posts.map (p) ->
      #       title: p.title
      #       url: base_url + '/t/' + p.slug
      #       updated_at: p.last_posted_at
      #     resp = {}
      #     resp[type] = posts
      #     callback resp
      #
      #   ).bind(this)
      #   error: ((xhr, status, err) ->
      #     console.error "Error loading posts: ", url, status, err.toString()
      #   ).bind(this)

    create_url: (subject) ->
      unless subject.meta_data.zooniverse_id?
        console.warn "Warning: Meta data field, zooniverse_id, does not exist for this subject."
        return null
      url = "https://www.zooniverse.org/projects/#{@options.account_username}/#{@options.project_name}/talk/subjects/#{subject.meta_data.zooniverse_id}/"

    # this method doesn't yet do anytying
    search_url: (term) ->
      # @options.base_url + "/search?search=#{term}"
      null

# @cjsx React.DOM

React                         = require 'react'

module.exports =

  class DiscourseConnector
    constructor: (@options) ->

    fetchPosts: (type, id, callback) ->
      url = '/proxy/forum'
      url += '/search.json?search=' + id
      $.ajax
        url: url
        dataType: "json"
        success: ((resp) =>
          # console.log 'FETCHED posts: ', resp

          posts = resp.topic_list?.topics ? []
          base_url = @options.base_url
          posts = posts.map (p) ->
            title: p.title
            url: base_url + '/t/' + p.slug
            updated_at: p.last_posted_at
          callback subject_set: posts

        ).bind(this)
        error: ((xhr, status, err) ->
          console.error "Error loading posts: ", url, status, err.toString()
        ).bind(this)

    create_url: ->
      @options.base_url

    search_url: (term) ->
      @options.base_url + "/search?search=#{term}"

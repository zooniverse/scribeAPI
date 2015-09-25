# @cjsx React.DOM

React = require 'react'

module.exports =

  class DiscourseConnector
    constructor: (@options, @project) ->

    fetchPosts: (type, id, callback) ->
      # fetchPosts: (terms, callback) ->

      url = '/proxy/forum'
      url += '/search.json?q=' + id
      $.ajax
        url: url
        dataType: "json"
        success: ((resp) =>

          posts = resp.posts ? []
          # console.log 'FETCHED posts: ', resp, posts

          base_url = @options.base_url
          posts = posts.map (p) ->
            title: p.blurb
            excerpt: p.blurb
            author: p.username
            url: base_url + '/t/' + p.topic_slug
            updated_at: p.updated_at
          resp = {}
          resp[type ? 'subjects'] = posts
          callback? resp

        ).bind(this)
        error: ((xhr, status, err) ->
          console.error "Error loading posts: ", url, status, err.toString()
        ).bind(this)

    create_url: (obj) ->
      # It's a subject set:
      # if obj.subjects?
       #  title = "#{@project.title} #{@project.term('subject set')} #{obj.id}"
        # url = "#{window.location.protocol}//#{window.location.origin}/#/mark/?subject_set_id=#{obj.id}"
      # else

      title = "#{@project.title} #{@project.term('subject')} #{obj.id}"
      url = "#{window.location.origin}/#/mark?subject_set_id=#{obj.subject_set_id}&selected_subject_id=#{obj.id}"
  
      line = '_'.repeat [80,Math.max(title.length, url.length)].min
      body = "\n\n#{line}\n#{title}\n#{url}"

      category = "Emigrant Records Discussion"
      
      @options.base_url + "/new-topic?title=#{encodeURIComponent(title)}&body=#{encodeURIComponent(body)}&category=#{category}"

    search_url: (term) ->
      @options.base_url + "/search?q=#{term}"

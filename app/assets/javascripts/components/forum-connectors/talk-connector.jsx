/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
/** @jsx React.DOM */ let TalkConnector;

const React = require("react");

module.exports = TalkConnector = class TalkConnector {
  constructor(options) {
    this.options = options;
  }

  // this method doesn't yet do anything
  fetchPosts(type, id, callback) {
    return null;
  }
  // url = '/proxy/forum'
  // url += '/search.json?search=' + id
  // $.ajax
  //   url: url
  //   dataType: "json"
  //   success: ((resp) =>
  //
  //     posts = resp.topic_list?.topics ? []
  //     base_url = @options.base_url
  //     posts = posts.map (p) ->
  //       title: p.title
  //       url: base_url + '/t/' + p.slug
  //       updated_at: p.last_posted_at
  //     resp = {}
  //     resp[type] = posts
  //     callback resp
  //
  //   ).bind(this)
  //   error: ((xhr, status, err) ->
  //     console.error "Error loading posts: ", url, status, err.toString()
  //   ).bind(this)

  create_url(subject) {
    let url;
    if (subject.meta_data.zooniverse_id == null) {
      console.warn(
        "Warning: Meta data field, zooniverse_id, does not exist for this subject."
      );
      return null;
    }
    return (url = `https://www.zooniverse.org/projects/${
      this.options.account_username
      }/${this.options.project_name}/talk/subjects/${
      subject.meta_data.zooniverse_id
      }/`);
  }

  // this method doesn't yet do anything
  search_url(term) {
    // @options.base_url + "/search?search=#{term}"
    return null;
  }
};

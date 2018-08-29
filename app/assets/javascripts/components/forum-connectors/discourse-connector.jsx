/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

 const DiscourseConnector = class DiscourseConnector {
  constructor(options, project) {
    this.options = options;
    this.project = project;
  }

  fetchPosts(type, id, callback) {
    // fetchPosts: (terms, callback) ->

    // url = '/proxy/forum'
    let url = this.options.base_url;
    url += `/search.json?q=${id}`;
    return $.ajax({
      url,
      dataType: "json",
      success: (resp => {
        let posts = resp.posts != null ? resp.posts : [];

        const { base_url } = this.options;
        posts = posts.map(p => ({
          title: p.blurb,
          excerpt: p.blurb,
          author: p.username,
          url: base_url + "/t/" + p.topic_slug,
          updated_at: p.updated_at
        }));
        resp = {};
        resp[type != null ? type : "subjects"] = posts;
        return typeof callback === "function" ? callback(resp) : undefined;
      }).bind(this),
      error: (xhr, status, err) => {
        return console.error(
          "Error loading posts: ",
          url,
          status,
          err.toString()
        );
      }
    });
  }

  create_url(obj) {
    // It's a subject set:
    // if obj.subjects?
    //  title = "#{@project.title} #{@project.term('subject set')} #{obj.id}"
    // url = "#{window.location.protocol}//#{window.location.origin}/#/mark/?subject_set_id=#{obj.id}"
    // else

    let title;
    if (obj == null) {
      return null;
    }

    if (this.project != null) {
      title = `${this.project.title} ${this.project.term("subject")} ${obj.id}`;
    }
    const url = `${window.location.origin}/#/mark?subject_set_id=${
      obj.subject_set_id
      }&selected_subject_id=${obj.id}`;

    const line = "_".repeat([80, Math.max(title.length, url.length)].min);
    const body = `\n\n${line}\n${title}\n${url}`;

    const category = "Emigrant Records Discussion";

    return (
      this.options.base_url +
      `/new-topic?title=${encodeURIComponent(title)}&body=${encodeURIComponent(
        body
      )}&category=${category}`
    );
  }

  search_url(term) {
    return this.options.base_url + `/search?q=${term}`;
  }
};
module.exports = DiscourseConnector;

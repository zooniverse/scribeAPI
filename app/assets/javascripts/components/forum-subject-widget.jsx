/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */


import React from "react";
import ReactDOM from "react-dom";
import PropTypes from 'prop-types';
import ForumConnectors from "./forum-connectors/index.jsx";
import createReactClass from "create-react-class";

export default createReactClass({
  displayName: "ForumSubjectWidget",
  resizing: false,

  getDefaultProps() {
    return {
      project: null,
      subject_set: null,
      subject: null
    };
  },

  propTypes: {
    project: PropTypes.object
  },

  getInitialState() {
    return {
      connector: null,
      posts: {},
      fetch_status: {}
    };
  },

  componentWillReceiveProps(new_props) {
    let connector;
    const { project } = new_props; // result[0]

    if ((project.forum != null ? project.forum.type : undefined) != null) {
      if (
        ForumConnectors[
          project.forum != null ? project.forum.type : undefined
        ] == null
      ) {
        console.warn(
          `Unsupported forum type. No connector defined for ${
            project.forum.type
          }`
        );
      } else {
        connector = new ForumConnectors[project.forum.type](
          project.forum,
          project
        );
      }
    }

    if (connector != null) {
      return this.setState({ connector }, () => {
        if (new_props.subject != null) {
          return this.fetchPosts("subject", new_props.subject.id);
        }
      });
    }
  },

  fetchPosts(type, id) {
    // If we've already fetched or are fetching posts for this type & id, abort
    if (this.state.fetch_status[`${type}.${id}`] != null) {
      return;
    }

    // For duration of fetch, status of this fetch is 'fetching'
    return this.setState(
      {
        fetch_status: $.extend(this.state.fetch_status, {
          [`${type}.${id}`]: "fetching"
        }),
        loading: true
      },
      () => {
        return this.state.connector.fetchPosts(type, id, posts => {
          this.setState({ loading: false });

          // Save posts to state as well as setting fetch_status for this type&id to 'fetched'
          return this.setState({
            posts,
            fetch_status: $.extend(this.state.fetch_status, {
              [`${type}.${id}`]: "fetched"
            })
          });
        });
      }
    );
  },

  handleSearchFormSubmit(e) {
    e.preventDefault();
    const term =
      this.refs.search_term != null
        ? ReactDOM.findDOMNode(this.refs.search_term).value.trim()
        : undefined;
    const url = this.state.connector.search_url(term);
    return window.open(url, "_blank");
  },

  render() {
    if (this.state.connector == null) {
      return null;
    }
    const create_url = this.state.connector.create_url(this.props.subject);
    const search_enabled = this.state.connector.search_url() != null;

    const subject_posts =
      this.state.posts.subject != null
        ? this.state.posts.subject
        : this.state.posts.subject_set != null
          ? this.state.posts.subject_set
          : [];
    return (
      <div className="forum-subject-widget">
        {search_enabled ? (
          <form
            onSubmit={this.handleSearchFormSubmit}
            method="get"
            action="javascript:void(0);"
          >
            <input type="text" ref="search_term" placeholder="Search forum" />
          </form>
        ) : (
          undefined
        )}
        {(() => {
          if (this.state.loading && search_enabled) {
            return (
              <span>
                Searching for discussions about this{" "}
                {this.props.project.term("subject")}
                ...
              </span>
            );
          } else if (subject_posts.length > 0) {
            return (
              <span>
                {`\
Discussion about this `}
                {this.props.project.term("subject")}
                {`:\
`}
                <ul>
                  {Array.from(subject_posts).map((post, i) => (
                    <li key={i}>
                      {`\
\"`}
                      <a target="_blank" href={post.url}>
                        {post.excerpt.truncate(70)}
                      </a>
                      {`\"\
`}
                      <br />– {post.author}, {moment(post.updated_at).fromNow()}
                    </li>
                  ))}
                </ul>
              </span>
            );
          }
        })()}
        {create_url != null ? (
          <a target="_blank" className="forum-link" href={create_url}>
            {" "}
            Discuss this {this.props.project.term("subject set")}.
          </a>
        ) : (
          <p>
            Oops! Disscussions have not been set up for this{" "}
            {this.props.project.term("subject set")}.
          </p>
        )}
      </div>
    );
  }
});
window.React = React;

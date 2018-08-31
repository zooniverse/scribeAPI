/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const API = require("./api.jsx");
const queryString = require('query-string');

module.exports = {
  componentDidMount() {
    // Fetching a single subject?
    if (this.props.match.params.subject_id != null) {
      return this.fetchSubject(this.props.match.params.subject_id);

      // Fetching subjects by current workflow and optional filters:
    } else {
      let query = queryString.parse(this.props.location);
      // Gather filters by which to query subjects
      const params = {
        parent_subject_id: this.props.match.params.parent_subject_id,
        group_id: query.group_id != null ? query.group_id : null,
        subject_set_id:
          query.subject_set_id != null
            ? query.subject_set_id
            : null
      };
      return this.fetchSubjects(params);
    }
  },

  orderSubjectsByY(subjects) {
    return subjects.sort(function(a, b) {
      if (a.region.y >= b.region.y) {
        return 1;
      } else {
        return -1;
      }
    });
  },

  // Fetch a single subject:
  fetchSubject(subject_id) {
    const request = API.type("subjects").get(subject_id);

    this.setState({
      subject: []
    });

    return request.then(subject => {
      return this.setState(
        {
          subject_index: 0,
          subjects: [subject]
        },
        () => {
          if (this.fetchSubjectsCallback != null) {
            return this.fetchSubjectsCallback();
          }
        }
      );
    });
  },

  fetchSubjects(params, callback) {
    const _params = $.extend(
      {
        workflow_id: this.getActiveWorkflow().id,
        limit: this.getActiveWorkflow().subject_fetch_limit
      },
      params
    );
    return API.type("subjects")
      .get(_params)
      .then(subjects => {
        if (subjects.length === 0) {
          this.setState({ noMoreSubjects: true });
        } else {
          this.setState({
            subject_index: 0,
            subjects: this.orderSubjectsByY(subjects),
            subjects_next_page: subjects[0].getMeta("next_page")
          });
        }

        // Does including instance have a defined callback to call when new subjects received?
        if (this.fetchSubjectsCallback != null) {
          return this.fetchSubjectsCallback();
        }
      });
  }
};

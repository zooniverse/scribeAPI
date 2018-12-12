import React from 'react'
import { withRouter } from 'react-router'
import queryString from 'query-string'

import MainHeader from '../partials/main-header.jsx'
import Footer from '../partials/footer.jsx'

import BrowserWarning from './browser-warning.jsx'
import { contextTypes } from './app-context.jsx'

@withRouter
export class App extends React.Component {
  static childContextTypes = contextTypes;

  constructor() {
    super()
    this.state = {
      routerRunning: false,
      user: null,
      loginProviders: []
    }
  }

  getGroupId() {
    let query = queryString.parse(this.props.location.search)
    return query.group_id
  }

  getChildContext() {
    const { project } = window
    return {
      project,
      onCloseTutorial: this.setTutorialComplete.bind(this),
      user: this.state.user,
      groupId: this.getGroupId()
    }
  }

  componentDidMount() {
    this.fetchUser()
  }

  componentWillReceiveProps(nextProps) {
    const { location, history: { action } } = nextProps
    if (location !== this.props.location && action === 'PUSH') {
      // navigated to a new page!
      window.scrollTo(0, 0)
    }
  }

  fetchUser() {
    this.setState({
      error: null
    })
    const request = $.getJSON('/current_user')

    request.done(result => {
      if (result == null) {
        return
      }

      if (result.data) {
        this.setState({
          user: result.data
        })
      }

      if (result.meta != null && result.meta.providers) {
        this.setState({ loginProviders: result.meta.providers })
      }
    })

    request.fail(error => {
      this.setState({
        loading: false,
        error: 'Having trouble logging you in'
      })
    })
  }

  setTutorialComplete() {
    const previously_saved =
      (this.state.user != null
        ? this.state.user.tutorial_complete
        : undefined) != null

    // Immediately amend user object with tutorial_complete flag so that we can hide the Tutorial:
    this.setState((prevState) => ({
      user: $.extend(prevState.user || {}, {
        tutorial_complete: true
      })
    }))

    // Don't re-save user.tutorial_complete if already saved:
    if (previously_saved) {
      return
    }

    const request = $.post('/tutorial_complete')
    request.fail(error => {
      console.log('failed to set tutorial value for user')
    })
  }

  render() {
    const { project } = window
    if (project == null) {
      return null
    }

    const style = {}
    if (project.background != null) {
      style.backgroundImage = `url(${project.background})`
    }

    return (
      <div>
        <div className="readymade-site-background" style={style}>
          <div className="readymade-site-background-effect"></div>
        </div>
        <div className="panoptes-main">
          <MainHeader
            workflows={project.workflows}
            feedbackFormUrl={project.feedback_form_url}
            discussUrl={project.discuss_url}
            blogUrl={project.blog_url}
            pages={project.pages}
            short_title={project.short_title}
            logo={project.logo}
            menus={project.menus}
            user={this.state.user}
            loginProviders={this.state.loginProviders}
            onLogout={() => this.setState({ user: null })}
          />
          <div className="main-content">
            <BrowserWarning />
            {this.props.children}
          </div>
          <Footer
            privacyPolicy={project.privacy_policy}
            menus={project.menus}
            partials={project.partials}
          />
        </div>
      </div>
    )
  }
}

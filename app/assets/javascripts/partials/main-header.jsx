import React from 'react'
import { NavLink } from 'react-router-dom'
import { AppContext } from '../components/app-context.jsx'
import Login from '../components/login.jsx'

@AppContext
export default class MainHeader extends React.Component {
  static defaultProps = {
    user: null,
    loginProviders: []
  };

  render() {
    let showFeedbackTab = false
    const groupId = this.props.context.groupId

    return (
      <header className="main-header">
        <nav className="main-nav main-header-group">
          <NavLink to="/" activeClassName="selected" className="main-header-item logo">
            {this.props.logo && <img src={this.props.logo} /> || this.props.short_title}
          </NavLink>
          {
            // Workflows tabs:
            this.props.workflows.filter(w =>
              ['transcribe', 'mark', 'verify'].includes(w.name)
            )
              .sort((w1, w2) => w1.order > w2.order ? 1 : -1)
              .map((workflow, key) => {
                const
                  title = workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
                return (
                  <NavLink key={key}
                    isActive={(match, location) => new RegExp(`^\\/${workflow.name}(\\/|$)`).test(location.pathname)}
                    to={`/${workflow.name + (groupId && ('?group_id=' + groupId) || '')}`} activeClassName="selected" className={`main-header-item ${workflow.name}`}>{title}</NavLink>
                )
              })
          }
          {// Page tabs, check for main menu
            this.props.menus != null && this.props.menus.main != null
              ? this.props.menus.main.map(
                (item, i) =>
                  item.page != null
                    ? <NavLink key={item.page} to={`/${item.page}`} activeClassName="selected" className="main-header-item">{item.label}</NavLink>
                    : item.url != null
                      ? <a href={`${item.url}`} className="main-header-item">{item.label}</a>
                      : <a className="main-header-item">{item.label}</a>)
              : // Otherwise, just list all the pages in default order
              this.props.pages != null
              && this.props.pages.map((page, key) => {
                const
                  formatted_name = page.name.replace('_', ' ')
                return (
                  <NavLink key={key} to={`/${page.name.toLowerCase()}`} activeClassName="selected" className="main-header-item">{formatted_name}</NavLink>
                )
              })}
          {
            // include feedback tab if defined
            this.props.feedbackFormUrl != null && showFeedbackTab &&
            <a className="main-header-item" href={this.props.feedbackFormUrl}>Feedback</a>
          }
          {// include blog tab if defined
            this.props.blogUrl != null &&
            <a target="_blank" className="main-header-item" href={this.props.blogUrl}>Blog</a>
          }
          {// include blog tab if defined
            this.props.discussUrl != null &&
            <a target="_blank" className="main-header-item" href={this.props.discussUrl}>Discuss</a>
          }
          <Login user={this.props.user} loginProviders={this.props.loginProviders} onLogout={this.props.onLogout} />
        </nav>
      </header>
    )
  }
}

/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import ReactDOM from 'react-dom'

import marked from '../lib/marked.min.js'

import createReactClass from 'create-react-class'
import { App } from './app.jsx'
import { AppContext } from './app-context.jsx'
import { Route, Redirect, Switch } from 'react-router'
import { HashRouter } from 'react-router-dom'
import HomePage from './home-page.jsx'

import Mark from './mark/index.jsx'
import Transcribe from './transcribe/index.jsx'
import Verify from './verify/index.jsx'

// TODO Group routes currently not implemented
import GroupPage from './group-page.jsx'
import GroupBrowser from './group-browser.jsx'

import Project from '../models/project.js'
import API from '../lib/api.jsx'

function getComponent(name) {
  switch (name) {
    case 'mark':
      return Mark
    case 'transcribe':
      return Transcribe
    case 'verify':
      return Verify
  }
}
export default class AppRouter {
  constructor() {
    API.type('projects')
      .get()
      .then(result => {
        window.project = new Project(result[0])
        this.runRoutes(window.project)
      })
  }

  runRoutes(project) {
    let w, i
    const routes = (
      <App>
        <Switch>
          <Redirect from="/home" to="/" />
          <Route exact name="home" path="/" component={HomePage} />
          {(() => {
            const result = []
            for (w of Array.from(project.workflows)) {
              if (['mark', 'transcribe', 'verify'].includes(w.name)) {
                result.push(w)
              }
            }
            return result
          })().map((workflow, key) => {
            const component = getComponent(workflow.name)
            return (
              <Route
                exact
                key={key}
                path={'/' + workflow.name}
                component={component}
                name={workflow.name}
              />
            )
          })}
          {(() => {
            const result1 = []
            for (i = 0; i < project.workflows.length; i++) {
              w = project.workflows[i]
              if (['mark'].includes(w.name)) {
                result1.push(w)
              }
            }
            return result1
          })().map((workflow, key) => {
            const component = getComponent(workflow.name)
            return (
              <Route
                exact
                key={key}
                path={'/' + workflow.name + '/:subject_set_id' + '/:subject_id'}
                component={component}
                name={workflow.name + '_specific_subject'}
              />
            )
          })}
          {(() => {
            const result2 = []
            for (i = 0; i < project.workflows.length; i++) {
              w = project.workflows[i]
              if (['mark'].includes(w.name)) {
                result2.push(w)
              }
            }
            return result2
          })().map((workflow, key) => {
            const component = getComponent(workflow.name)
            return (
              <Route
                exact
                key={key}
                path={'/' + workflow.name + '/:subject_set_id'}
                component={component}
                name={workflow.name + '_specific_set'}
              />
            )
          })}
          {(() => {
            const result3 = []
            for (i = 0; i < project.workflows.length; i++) {
              w = project.workflows[i]
              if (['transcribe', 'verify'].includes(w.name)) {
                result3.push(w)
              }
            }
            return result3
          })().map((workflow, key) => {
            const component = getComponent(workflow.name)
            return (
              <Route
                exact
                key={key}
                path={'/' + workflow.name + '/:subject_id'}
                component={component}
                name={workflow.name + '_specific'}
              />
            )
          })}
          {(() => {
            const result4 = []
            for (i = 0; i < project.workflows.length; i++) {
              w = project.workflows[i]
              if (['transcribe'].includes(w.name)) {
                result4.push(w)
              }
            }
            return result4
          })().map((workflow, key) => {
            const component = getComponent(workflow.name)
            return (
              <Route
                exact
                key={key}
                path={'/' + workflow.name + '/:workflow_id' + '/:parent_subject_id'}
                component={component}
                name={workflow.name + '_entire_page'}
              />
            )
          })}
          {// Project-configured pages:
            project.pages != null && project.pages.map((page, key) => {
              return (
                <Route
                  exact
                  key={key}
                  path={'/' + page.name}
                  component={this.controllerForPage(page)}
                />
              )
            })
          }
          <Route path="/groups/:group_id" component={GroupPage} name="group_show" />
          <Route path="/groups" component={GroupBrowser} name="groups" />
        </Switch>
      </App>
    )
    ReactDOM.render(<HashRouter>{routes}</HashRouter>, document.getElementById('app'))
    // return Router.run(routes, (Handler, state) =>
    //   React.render(<Handler />, document.body)
    // );
  }

  controllerForPage(page) {
    return AppContext(createReactClass({
      displayName: `${page.name}Page`,

      componentWillMount() { },
      // pattern = new RegExp('^(field_guide#(.*))')
      // selectedID = pattern.match("#{window.location.hash}")
      // if selectedID
      //   $('.selected-content').removeClass("selected-content")

      //   $("div#" + selectedID).addClass("selected-content"))
      //   $("a#" + selectedID).addClass("selected-content"))

      componentDidMount() {
        const pattern = new RegExp('#/[A-z]*#(.*)')
        const selectedID = `${window.location.hash}`.match(pattern)

        if (selectedID) {
          $('.selected-content').removeClass('selected-content')

          $(`div#${selectedID[1]}`).addClass('selected-content')
          $(`a#${selectedID[1]}`).addClass('selected-content')
        }

        const elms = $(ReactDOM.findDOMNode(this)).find('a.about-nav')
        elms.on('click', function (e) {
          e.preventDefault()
          $('.selected-content').removeClass('selected-content')
          $(this).addClass('selected-content')

          const divId = $(this).attr('href')
          return $(divId).addClass('selected-content')
        })

        const el = $(ReactDOM.findDOMNode(this)).find('#accordion')
        return el.accordion({
          collapsible: true,
          active: false,
          heightStyle: 'content'
        })
      },

      navToggle(e) { },

      render() {
        const formatted_name = page.name.replace('_', ' ')
        return (
          <div className="page-content custom-page" id={`${page.name}`}>
            <h1>{formatted_name}</h1>
            <div dangerouslySetInnerHTML={{ __html: marked(page.content) }} />
            {page.group_browser != null && page.group_browser !== '' &&
              <div className="group-area">
                <GroupBrowser project={this.props.project} title={page.group_browser} />
              </div>}
            <div className="updated-at">Last Update {page.updated_at}</div>
          </div>
        )
      }
    }))
  }
}

$(document).ready(() =>
  new AppRouter())

React                   = require 'react'

Footer = React.createClass
  displayName: 'Footer'

  propTypes:->
    privacyPolicy: @props.privacyPolicy

  getInitialState: ->
    categories: null

  render: ->
    <div id="footer" className="scribe-footer">
      <a href="http://scribeproject.github.io/" className="scribe-logo-container">
        <img src={"/assets/scribe-logo-inv.png"} alt={"Scribe Logo"} ></img>
      </a>

      <div className="scribe-footer-content">
        <div className="scribe-footer-heading">This project is built using Scribe, a framework for crowdsourcing the transcription of text-based documents.</div>

        {if @state.categories?
          <div className="scribe-footer-projects">
            {for {category, projects}, i in @state.categories
              <div key={i} className="scribe-footer-category">
                <div className="scribe-footer-category-title">{category}</div>
                {for project, i in projects
                  <div key={i} className="scribe-footer-project">
                    <a href={project.url}>{project.name}</a>
                  </div>
                }
                <div className="scribe-footer-project"></div>
              </div>
            }
          </div>
        }

        <div className="scribe-footer-general">
          <div className="scribe-footer-category">
            <a href={@props.privacyPolicy}>Privacy Policy</a>
          </div>

          <div className="scribe-footer-category">
            <a href="https://github.com/zooniverse/ScribeAPI">Source & Bugs</a>
          </div>
        </div>
      </div>
    </div>

module.exports = Footer
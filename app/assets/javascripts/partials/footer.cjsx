React                   = require 'react'

Footer = React.createClass
  displayName: 'Footer'

  getInitialState: ->
    categories: null

  render: ->
    <div id="footer" className="zooniverse-footer">
      <a href="http://scribe.nypl.org/" className="zooniverse-logo-container">
        <img src={"/assets/scribe-logo-inv.png"} alt={"Scribe Logo"} ></img>
      </a>

      <div className="zooniverse-footer-content">
        <div className="zooniverse-footer-heading">This project is built using Scribe, a framework for crowdsourcing the transcription of text-based documents.</div>

        {if @state.categories?
          <div className="zooniverse-footer-projects">
            {for {category, projects}, i in @state.categories
              <div key={i} className="zooniverse-footer-category">
                <div className="zooniverse-footer-category-title">{category}</div>
                {for project, i in projects
                  <div key={i} className="zooniverse-footer-project">
                    <a href={project.url}>{project.name}</a>
                  </div>
                }
                <div className="zooniverse-footer-project"></div>
              </div>
            }
          </div>
        }

        <div className="zooniverse-footer-general">
          <div className="zooniverse-footer-category">
            <a href="https://www.zooniverse.org/privacy">Privacy Policy</a>
          </div>

          <div className="zooniverse-footer-category">
            <a href="https://github.com/zooniverse/ScribeAPI">Source & Bugs</a>
          </div>
        </div>
      </div>
    </div>

module.exports = Footer
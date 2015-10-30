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

      <div className="scribe-footer-credits">
        <div>
          <p>A collaboration between
            <a href="http://www.nypl.org/collections/labs"><img src="/assets/nypllabs_logo.png" className="inline" alt="New York Public Library Labs" title="New York Public Library Labs" /></a>
            and <a href="https://www.zooniverse.org/"><img src="/assets/zooniverse_logo.png" className="inline" alt="Zooniverse" title="Zooniverse" /></a>
            with generous support from:</p>
          <p><a href="http://www.neh.gov/"><img src="/assets/neh_logo.png" alt="National Endowment for the Humanities" title="National Endowment for the Humanities" /></a></p>
        </div>
      </div>

    </div>

module.exports = Footer

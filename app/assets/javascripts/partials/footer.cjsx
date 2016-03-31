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
        <div className="scribe-footer-heading">This project is built using Scribe: document transcription, crowdsourced.</div>

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


        {
          if @props.menus? && @props.menus.footer?
            if @props.menus.footer.length > 0
              <div className="scribe-footer-general">
                for item, i in @props.menus.footer
                  if item.url?
                    <div className="scribe-footer-category custom-footer-link">
                      <a href={item.url}>{item.label}</a>
                    </div>
                  else
                    <div className="scribe-footer-category custom-footer-link">
                      {item.label}
                    </div>
              </div>
          else
            <div className="scribe-footer-general">
              <div className="scribe-footer-category">
                <a href={@props.privacyPolicy}>Privacy Policy</a>
              </div>
              <div className="scribe-footer-category">
                <a href="https://github.com/zooniverse/ScribeAPI">Source & Bugs</a>
              </div>
            </div>
        }


      </div>

      {
        if @props.partials? && @props.partials["footer"]?
          <div className="custom-footer" dangerouslySetInnerHTML={{__html: marked(@props.partials["footer"])}} />
      }

    </div>

module.exports = Footer

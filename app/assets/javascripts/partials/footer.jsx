/*
 * decaffeinate suggestions:
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react";

import createReactClass from "create-react-class";
const Footer = createReactClass({
  displayName: "Footer",

  propTypes() {
    return { privacyPolicy: this.props.privacyPolicy };
  },

  getInitialState() {
    return { categories: null };
  },

  render() {
    let i;
    return (
      <div id="footer" className="scribe-footer">
        <a href="http://scribeproject.github.io/" className="scribe-logo-container">
          <img src={"/assets/scribe-logo-inv.png"} alt={"Scribe Logo"} ></img>
        </a>
        <div className="scribe-footer-content">
          <div className="scribe-footer-heading">This project is built using Scribe: document transcription, crowdsourced.</div>
          {this.state.categories != null ? (
            <div className="scribe-footer-projects">
              {(() => {
                let j;
                const result = [];
                for (
                  j = 0, i = j;
                  j < this.state.categories.length;
                  j++ , i = j
                ) {
                  var { category, projects } = this.state.categories[i];
                  result.push(
                    <div key={i} className="scribe-footer-category">
                      <div className="scribe-footer-category-title">{category}</div>
                      {(() => {
                        const result1 = [];
                        for (i = 0; i < projects.length; i++) {
                          const project = projects[i];
                          result1.push(
                            <div key={i} className="scribe-footer-project">
                              <a href={project.url}>{project.name}</a>
                            </div>
                          );
                        }

                        return result1;
                      })()}
                      <div className="scribe-footer-project" />
                    </div>
                  );
                }

                return result;
              })()}
            </div>
          ) : undefined}
          {(() => {
            if (this.props.menus != null && this.props.menus.footer != null) {
              if (this.props.menus.footer.length > 0) {
                return (
                  <div className="scribe-footer-general">
                    {(() => {
                      const result2 = [];
                      for (i = 0; i < this.props.menus.footer.length; i++) {
                        const item = this.props.menus.footer[i];
                        if (item.url != null) {
                          result2.push(
                            <div className="scribe-footer-category custom-footer-link">
                              <a href={item.url}>{item.label}</a>
                            </div>
                          );
                        } else {
                          result2.push(
                            <div className="scribe-footer-category custom-footer-link">
                              {item.label}
                            </div>
                          );
                        }
                      }

                      return result2;
                    })()}
                  </div>
                );
              }
            } else {
              return (
                <div className="scribe-footer-general">
                  <div className="scribe-footer-category">
                    <a href={this.props.privacyPolicy}>Privacy Policy</a>
                  </div>
                  <div className="scribe-footer-category">
                    <a href="https://github.com/zooniverse/ScribeAPI">Source &amp; Bugs</a>
                  </div>
                </div>
              );
            }
          })()}
        </div>
        {this.props.partials != null &&
          this.props.partials["footer"] != null ? (
            <div className="custom-footer" dangerouslySetInnerHTML={{ __html: marked(this.props.partials["footer"]) }} />
          ) : undefined}
      </div>
    );
  }
});

export default Footer;

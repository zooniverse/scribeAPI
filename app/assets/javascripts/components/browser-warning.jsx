import React from 'react'
import GenericButton from './buttons/generic-button.jsx'

export default class BrowserWarning extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      showing: !this.browserAcceptable(),
      isTouchDevice: this.isTouchDevice()
    }
  }

  browserAcceptable() {
    let pass = true
    // Need some kind of flexbox support:
    if (pass) {
      pass = Modernizr.flexbox
    }
    // Need promises to work (note this may punish IE users even though we've shimmed it):
    if (pass) {
      pass = Modernizr.promises
    }

    // Should warn about touch devices.
    if (pass) {
      pass = !this.isTouchDevice()
    }

    return pass
  }

  isTouchDevice() {
    // It's not enough to test Modernizr.touchevents
    // because many browsers implement touch events regardless of hardware
    const deviceAgent = navigator.userAgent.toLowerCase()
    const ret =
      deviceAgent.match(/(iphone|ipod|ipad)/) ||
      deviceAgent.match(/(android)/) ||
      deviceAgent.match(/(iemobile)/) ||
      deviceAgent.match(/iphone/i) ||
      deviceAgent.match(/ipad/i) ||
      deviceAgent.match(/ipod/i) ||
      deviceAgent.match(/blackberry/i) ||
      deviceAgent.match(/bada/i)
    return ret
  }

  close() {
    this.setState({ showing: false })
  }

  render() {
    if (!this.state.showing) {
      return null
    }

    return (
      <div className="browser-warning">
        {this.state.isTouchDevice ?
          <p>
            Welcome! Thanks for your interest in {project.title}. The app is
            designed for desktops. For the full experience, come back later from
            your laptop or desktop.
          </p> :
          <div>
            <p>
              Welcome! Thanks for your interest in {project.title}. Please note
              that your browser may not work well here. For the best experience,
              please use the most recent version of one of the following
              supported browsers:
            </p>
            <ul>
              <li>
                <a href="https://www.mozilla.org/en-US/firefox/new/">Firefox</a>
              </li>
              <li>
                <a href="https://www.google.com/chrome/browser/desktop/index.html">
                  Chrome
                </a>
              </li>
              <li>
                <a href="https://www.apple.com/safari/">Safari</a>
              </li>
              <li>
                <a href="https://www.microsoft.com/en-us/windows/microsoft-edge">
                  Edge
                </a>
              </li>
            </ul>
          </div>
        }
        <GenericButton label="Dismiss" major={true} onClick={this.close.bind(this)} />
      </div>
    )
  }
}

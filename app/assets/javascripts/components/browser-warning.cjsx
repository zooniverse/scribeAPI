React         = require("react")
GenericButton    = require './buttons/generic-button'

module.exports = React.createClass
  displayName : "BrowserWarning"

  getInitialState: ->
    showing: ! @browserAcceptable()
    isTouchDevice: @isTouchDevice()

  browserAcceptable: ->
    pass = true
    # Need some kind of flexbox support:
    pass &&= Modernizr.flexbox
    # Need promises to work (note this may punish IE users even though we've shimmed it):
    pass &&= Modernizr.promises

    # Should warn about touch devices. 
    pass &&= ! @isTouchDevice()

    pass

  isTouchDevice: ->
    # It's not enough to test Modernizr.touchevents
    # because many browsers implement touch events regardless of hardware
    deviceAgent = navigator.userAgent.toLowerCase()
    ret = (
      deviceAgent.match(/(iphone|ipod|ipad)/) ||
      deviceAgent.match(/(android)/)  ||
      deviceAgent.match(/(iemobile)/) ||
      deviceAgent.match(/iphone/i) ||
      deviceAgent.match(/ipad/i) ||
      deviceAgent.match(/ipod/i) ||
      deviceAgent.match(/blackberry/i) ||
      deviceAgent.match(/bada/i)
    )
    ret

  close: ->
    @setState showing: false

  render:->
    return null if ! @state.showing

    <div className="browser-warning">
      <a className="modal-close-button" onClick={@closeModal}></a>
      <p>Please note: Your browser/device may not work well with {project.title}.</p>
      { if @state.isTouchDevice
          <p>Touch interfaces aren't well supported.</p>
        else
          <div>
            <p>For the best experience, please use the most recent version of one of the following supported browsers:</p>
            <ul>
              <li><a href="https://www.mozilla.org/en-US/firefox/new/">Firefox</a></li>
              <li><a href="https://www.google.com/chrome/browser/desktop/index.html">Chrome</a></li>
              <li><a href="https://www.apple.com/safari/">Safari</a></li>
              <li><a href="http://windows.microsoft.com/en-US/internet-explorer/download-ie">Internet Explorer</a></li>
            </ul>
          </div>
      }

      <GenericButton label="Dismiss" major=true onClick={@close} />
    </div>


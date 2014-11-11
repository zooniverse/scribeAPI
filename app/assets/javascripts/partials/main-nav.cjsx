React = require 'react'

module.exports = React.createClass
  displayName: 'MainNav'

  render: ->
    <nav className="main-nav main-header-group">
      <a href="/" root={true} className="main-header-item logo">
        &nbsp;
        Scribe 2.0
      </a>
      <a href="/#/mark" className="main-header-item">Mark</a>
      <a href="/#/transcribe" className="main-header-item">Transcribe</a>
      <a href="/#/science" className="main-header-item">Science</a>
    </nav>

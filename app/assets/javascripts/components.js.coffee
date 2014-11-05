React = require('react')
App = require("./components/app")

$(document).ready ->
  React.renderComponent(App(null), document.body)

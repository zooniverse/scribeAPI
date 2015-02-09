# @cjsx React.DOM
React = require 'react'

TextRowTool = React.createClass
  displayName: 'TextRowTool'

  render: ->
    <g>
      <text fontSize="40" fill="blue">{"BLAH BLH BLAH"}</text>
    </g>
module.exports = TextRowTool
  
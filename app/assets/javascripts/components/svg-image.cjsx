# @cjsx React.DOM

React = require 'react'

# React.DOM doesn't include an SVG <image> tag
# (because of its namespaced `xlink:href` attribute, I think),
# so this fakes one by wrapping it in a <g>.

module.exports = React.createClass
  displayName: 'SVGImage'

  getDefaultProps: ->
    src: ''
    width: 0
    height: 0

  render: ->
    imageHTML = "<image xlink:href='#{@props.src}' width='#{@props.width}' height='#{@props.height}' />"
    @transferPropsTo <g className="svg-image-container" dangerouslySetInnerHTML={__html: imageHTML} />

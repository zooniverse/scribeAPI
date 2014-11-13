# @cjsx React.DOM

React = require 'react'

module.exports = React.createClass
  displayName: 'DoneCheckbox'

  getInitialState: ->
    fillColor: 'rgb(100,200,50)'
    strokeColor: 'rgb(0,0,0)'
    strokeWidth: 4
    borderRadius: 10
    width: 100
    height: 40

  render: ->
    <g 
      onClick     = {@props.handleMarkDone}
      transform   = {@props.transform} 
      className   = "clickable drawing-tool-done-button" 
      stroke      = {@state.strokeColor} 
      strokeWidth = {@state.strokeWidth} >

      <rect 

        onMouseOver = {=>console.log 'MOUSE OVER'}
        transform = "translate(0,-5)"
        rx        = "#{@state.borderRadius}" 
        ry        = "#{@state.borderRadius}" 
        width     = "#{@state.width}" 
        height    = "#{@state.height}" 
        fill      = "#{@state.fillColor}" />
      <text
        transform = "translate(12,24)"
        fontSize  = "26">
        DONE
      </text>
    </g>


# # Fancy button with highlights and shit;
# <g dangerouslySetInnerHTML={{__html: "
#     <defs id=\"defs4\">
#       <linearGradient id=\"linearGradient3159\">
#         <stop id=\"stop3163\" style=\"stop-color:#000000;stop-opacity:0\" offset=\"0\"/>
#         <stop id=\"stop3161\" style=\"stop-color:#000000;stop-opacity:0.5\" offset=\"1\"/>
#       </linearGradient>
#       <linearGradient id=\"linearGradient3030\">
#         <stop id=\"stop3032\" style=\"stop-color:#ffffff;stop-opacity:1\" offset=\"0\"/>
#         <stop id=\"stop3034\" style=\"stop-color:#ffffff;stop-opacity:0\" offset=\"1\"/>
#       </linearGradient>
#       <linearGradient x1=\"120\" y1=\"10\" x2=\"120\" y2=\"50\" id=\"linearGradient3113\" xlink:href=\"#linearGradient3030\" gradientUnits=\"userSpaceOnUse\"/>
#       <radialGradient cx=\"120\" cy=\"170\" r=\"100\" fx=\"120\" fy=\"170\" id=\"radialGradient3165\" xlink:href=\"#linearGradient3159\" gradientUnits=\"userSpaceOnUse\" gradientTransform=\"matrix(0,-0.72727275,2,0,-220,170)\"/>
#     </defs>
#     <g id=\"layer1\" width=\"50%\" height=\"50%\">
#       <rect width=\"220\" height=\"80\" ry=\"40\" x=\"10\" y=\"10\" id=\"ButtonBase\" style=\"fill:currentColor;stroke:none\"/>
#       <rect width=\"220\" height=\"80\" ry=\"40\" x=\"10\" y=\"10\" id=\"ButtonGlow\" style=\"fill:#008000;stroke:none\"/>
#       <text x=\"120\" y=\"64.5\" id=\"text3198\" xml:space=\"preserve\" style=\"font-size:40px;text-align:center;text-anchor:middle;fill:#ffffff;stroke:none;font-family:Sans\"><tspan x=\"120\" y=\"64.5\" id=\"tspan3200\">DONE</tspan></text>
#       <path d=\"m 50 15 140 0 c 11.1 0 22.5 10.9 20 20 -1.8 6.6 -8.9 5 -20 5 L 50 40 C 38.9 40 31.8 41.6 30 35 27.5 25.9 38.9 15 50 15 z\" id=\"ButtonHighlight\" style=\"fill:url(#linearGradient3113)\"/>
#     </g>
# "}} />

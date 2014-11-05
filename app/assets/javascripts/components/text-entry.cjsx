# @cjsx React.DOM
React = require 'react'
Draggable = require '../lib/draggable'

TextEntryTool = React.createClass
  displayName: 'TextEntryTool'

  componentWillReceiveProps: ->
    return
    console.log 'RECEIVING PROPS...'
    @setProps
      top: @props.top
      left: @props.left
    
  render: ->

    style =
      top: "#{@props.top}"
      left: "#{@props.left}"
      'background-color': 'rgba(0,0,0,0.80)'
      'border-radius': '10px'
      'box-shadow': '4px 4px 10px #000'

    <div className="text-entry" style={style}>
      <div className="left">
        <div className="input_field state text">
          <a href="#" className="yellow button">ok</a>
          <input 
            type="text" 
            placeholder="Date" 
            className="" 
            role="textbox" 
          />
        </div>
      </div>
      <div className="right">
        <a href="#" className="blue button back">Back</a>
        <a href="#" className="red button skip">Skip</a>
        <a href="#" className="white button finish">Done</a>
      </div>
    </div>

module.exports = TextEntryTool
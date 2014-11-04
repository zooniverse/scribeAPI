# @cjsx React.DOM


ResizeButton = React.createClass
  displayName: 'ResizeButton'

  getInitialState: ->
    fillColor: '#26baff'
    strokeColor: '#000'
    strokeWidth: 1
    scrubberWidth: @props.scrubberWidth
    scrubberHeight: @props.scrubberHeight

  render: ->

    <Draggable
      onStart = {@props.handleResize}
      onDrag  = {@props.handleResize}
    >
      <g
        transform   = {@props.transform}
        className   = "clickable drawing-tool-resize-button"
        stroke      = {@state.strokeColor}
        strokeWidth = {@state.strokeWidth} >

        { if @props.workflow is "text-region"
          <rect
            width  = {@state.scrubberWidth}
            height = {@state.scrubberHeight}
            fill   = {@state.fillColor}
          />
        }
      </g>
    </Draggable>

window.ResizeButton = ResizeButton

markingTools = require 'components/mark/tools'

module.exports =

  showPreviousMarks: ->
    console.log 'showPreviousMarks()'
    # console.log 'PREVIOUS MARKS FROM SERVER: ', @props.subject.child_subjects_info
    previousMarks =
      for mark, i in @props.subject.child_subjects_info
        toolName = mark.data.toolName
        ToolComponent = markingTools[toolName]
        scale = @getScale()

        <ToolComponent
          key={mark._key}
          mark={mark.data}
          xScale={scale.horizontal}
          yScale={scale.vertical}
          disabled={true}
          isPriorMark={true}
          selected={true}
          getEventOffset={@getEventOffset}
          ref={@refs.sizeRect}
        />

    return <g>{previousMarks}</g>

  highlightMark: (mark, toolName) ->
    # DEBUG CODE
    # console.log 'TOOL NAME: ', toolName
    # console.log "highlightMark: ", mark
    highlight =
      # TODO: Note that x, y, w h aren't scaled properly:
      switch toolName
        when 'rectangleTool'
          # console.log "RECTANGLE TOOL FOLKS "
          <g>
            <rect
              className   = "mark-rectangle top"
              x           = 0
              y           = 0
              width       = { @state.imageWidth }
              height      = { mark.y }
              fill        = "rgba(0,0,0,0.6)"
            />
            <rect
              className   = "mark-rectangle bottom"
              x           = 0
              y           = { mark.y + mark.height }
              width       = { @state.imageWidth }
              height      = { @state.imageHeight - mark.y + mark.height }
              fill        = "rgba(0,0,0,0.6)"
            />
            <rect
              className   = "mark-rectangle left"
              x           = 0
              y           = { mark.y }
              width       = { mark.x }
              height      = { mark.height }
              fill        = "rgba(0,0,0,0.6)"
            />
            <rect
              className   = "mark-rectangle right"
              x           = { mark.x + mark.width}
              y           = { mark.y }
              width       = { @state.imageWidth - mark.width - mark.x }
              height      = { mark.height }
              fill        = "rgba(0,0,0,0.6)"
            />
          </g>
        when 'textRowTool'
          console.log 'TEXT ROW TOOL!'
          <g>
            <rect
              className   = "mark-rectangle"
              x           = 0
              y           = { 0 }
              width       = { @state.imageWidth }
              height      = { mark.yUpper }
              fill        = "rgba(0,0,0,0.6)"
            />

            <rect
              className   = "mark-rectangle"
              x           = 0
              y           = { mark.yLower }
              width       = { @state.imageWidth }
              height      = { @state.imageHeight - mark.yLower }
              fill        = "rgba(0,0,0,0.6)"
            />
          </g>

    return {highlight}

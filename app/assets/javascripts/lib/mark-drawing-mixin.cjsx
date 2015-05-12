module.exports =
  showPreviousMarks: ->
    # DEBUG CODE
    # console.log 'PREVIOUS MARKS: ', @props.subject.child_subjects_info
    previousMarks =
      for previousMark in @props.subject.child_subjects_info
        console.log "props in the mark-draw mixin", @props.subject
        switch previousMark.data.toolName
          when 'textRowTool'
            x = 0
            y = previousMark.data.yUpper
            width = @state.imageWidth
            height = previousMark.data.yLower - previousMark.data.yUpper
          when 'rectangleTool'
            x = previousMark.data.x
            y = previousMark.data.y
            width = previousMark.data.width
            height = previousMark.data.height
        <rect
          className   = "previous-mark"
          x           = { x }
          y           = { y }
          width       = { width }
          height      = { height }
          fill        = "rgba(0,0,0,0)"
          stroke      = "#f60"
          strokeWidth = "5px"
        />

    return <g>{previousMarks}</g>

  highlightMark: (mark, toolName) ->
    # DEBUG CODE
    # console.log 'TOOL NAME: ', toolName
    highlight =
      # TODO: Note that x, y, w h aren't scaled properly:
      switch toolName
        when 'rectangleTool'
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

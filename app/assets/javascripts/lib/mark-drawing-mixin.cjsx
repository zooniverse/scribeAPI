markingTools = require 'components/mark/tools'

module.exports =

#   PB: This appears unused. DEP
#   showPreviousMarks: ->
#     previousMarks =
#       for mark, i in @props.subject.child_subjects_info
#         toolName = mark.data.toolName
#         ToolComponent = markingTools[toolName]
#         scale = @getScale()
# 
#         <ToolComponent
#           key={mark._key}
#           mark={mark.data}
#           xScale={scale.horizontal}
#           yScale={scale.vertical}
#           disabled={true}
#           isPriorMark={true}
#           selected={true}
#           getEventOffset={@getEventOffset}
#           ref={@refs.sizeRect}
#         />
# 
#     return <g>{previousMarks}</g>

  highlightMark: (mark, toolName) ->
    switch toolName
      when 'rectangleTool'
        <g>
          <rect
            className   = "mark-rectangle top"
            x           = 0
            y           = 0
            width       = { @props.subject.width }
            height      = { mark.y }
            fill        = "rgba(0,0,0,0.6)"
          />
          <rect
            className   = "mark-rectangle bottom"
            x           = 0
            y           = { mark.y + mark.height }
            width       = { @props.subject.width }
            height      = { @props.subject.height - mark.y + mark.height }
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
            width       = { @props.subject.width - mark.width - mark.x }
            height      = { mark.height }
            fill        = "rgba(0,0,0,0.6)"
          />
        </g>
      when 'textRowTool'
        <g>
          <rect
            className   = "mark-rectangle"
            x           = 0
            y           = { 0 }
            width       = { @props.subject.width }
            height      = { mark.yUpper }
            fill        = "rgba(0,0,0,0.6)"
          />

          <rect
            className   = "mark-rectangle"
            x           = 0
            y           = { mark.yLower }
            width       = { @props.subject.width }
            height      = { @props.subject.height - mark.yLower }
            fill        = "rgba(0,0,0,0.6)"
          />
        </g>

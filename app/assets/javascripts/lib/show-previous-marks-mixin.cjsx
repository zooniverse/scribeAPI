module.exports =
  showPreviousMarks: ->
    previousMarks =
      for previousMark in @props.subject.child_subjects_info
        # DEBUG CODE
        switch previousMark.tool_type
          when 'textRowTool'
            x = 0
            y = previousMark.spec.yUpper
            width = @state.imageWidth
            height = previousMark.spec.yLower - previousMark.spec.yUpper
          when 'rectangleTool'
            x = previousMark.spec.x
            y = previousMark.spec.y
            width = previousMark.spec.width
            height = previousMark.spec.height
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
  #
  # displayRectangleToolHighlights: ->
  #   mark = {x: @props.subject.location.spec.x, y: @props.subject.location.spec.y, width: @props.subject.location.spec.width, height: @props.subject.location.spec.height}
  #   highlight =
  #       # TODO: Note that x, y, w h aren't scaled properly:
  #     <g>
  #       <rect
  #         className   = "mark-rectangle top"
  #         x           = 0
  #         y           = 0
  #         width       = { @state.imageWidth }
  #         height      = { mark.y }
  #         fill        = "rgba(0,0,0,0.6)"
  #       />
  #       <rect
  #         className   = "mark-rectangle bottom"
  #         x           = 0
  #         y           = { mark.y + mark.height }
  #         width       = { @state.imageWidth }
  #         height      = { @state.imageHeight - mark.y + mark.height }
  #         fill        = "rgba(0,0,0,0.6)"
  #       />
  #       <rect
  #         className   = "mark-rectangle left"
  #         x           = 0
  #         y           = { mark.y }
  #         width       = { mark.x }
  #         height      = { mark.height }
  #         fill        = "rgba(0,0,0,0.6)"
  #       />
  #       <rect
  #         className   = "mark-rectangle right"
  #         x           = { mark.x + mark.width}
  #         y           = { mark.y }
  #         width       = { @state.imageWidth - mark.width - mark.x }
  #         height      = { mark.height }
  #         fill        = "rgba(0,0,0,0.6)"
  #       />
  #     </g>
  #   return {highlight}



  showRectangleTranscribeTools: ->
    return null
    # console.log 'FOO'
    #   blah =
    #     if @props.workflow.name is 'transcribe' and @props.subject.location.spec.toolName is 'rectangleTool'
    #       isPriorAnnotation = true # ?
    #       <g key={@props.subject.id} className="marks-for-annotation" data-disabled={isPriorAnnotation}>
    #         {
    #           console.log '@props.subject.location.spec: ', @props.subject.location.spec
    #           # Represent the secondary subject as a rectangle mark
    #           # TODO Should really check the drawing tool used (encoded somehow in the 2ndary subject) and display a read-only instance of that tool. For now just defaulting to rect:
    #           ToolComponent = markingTools['rectangleTool']
    #           # TODO: Note that x, y, w h aren't scaled properly:
    #           mark = {x: @props.subject.location.spec.x, y: @props.subject.location.spec.y, width: @props.subject.location.spec.width, height: @props.subject.location.spec.height}
    #
    #           <g>
    #             <rect
    #               className   = "mark-rectangle top"
    #               x           = 0
    #               y           = 0
    #               width       = { @state.imageWidth }
    #               height      = { mark.y }
    #               fill        = "rgba(0,0,0,0.6)"
    #             />
    #             <rect
    #               className   = "mark-rectangle bottom"
    #               x           = 0
    #               y           = { mark.y + mark.height }
    #               width       = { @state.imageWidth }
    #               height      = { @state.imageHeight - mark.y + mark.height }
    #               fill        = "rgba(0,0,0,0.6)"
    #             />
    #             <rect
    #               className   = "mark-rectangle left"
    #               x           = 0
    #               y           = { mark.y }
    #               width       = { mark.x }
    #               height      = { mark.height }
    #               fill        = "rgba(0,0,0,0.6)"
    #             />
    #             <rect
    #               className   = "mark-rectangle right"
    #               x           = { mark.x + mark.width}
    #               y           = { mark.y }
    #               width       = { @state.imageWidth - mark.width - mark.x }
    #               height      = { mark.height }
    #               fill        = "rgba(0,0,0,0.6)"
    #             />
    #
    #             <ToolComponent
    #               key={@props.subject.id}
    #               mark={mark}
    #               xScale={scale.horizontal}
    #               yScale={scale.vertical}
    #               disabled={isPriorAnnotation}
    #               selected={mark is @state.selectedMark}
    #               getEventOffset={@getEventOffset}
    #               ref={@refs.sizeRect}
    #
    #               onSelect={@selectMark.bind this, @props.subject, mark}
    #             />
    #           </g>
    #         }
    #       </g>
    # return {blah}

module.exports =
  showPreviousMarks: ->


    previousMarks =
      for previousMark in @props.subject.child_subjects_info
        console.log 'PREVIOUS MARK: ', previousMark
        <rect
          className   = "previous-mark"
          x           = 0
          y           = { previousMark.spec.yUpper }
          width       = { @state.imageWidth }
          height      = { previousMark.spec.yLower - previousMark.spec.yUpper }
          fill        = "rgba(0,0,0,0)"
          stroke      = "#f60"
          strokeWidth = "5px"
        />

    console.log 'previousMarks: ', previousMarks

    # return <rect x=100 y=100 width=300 height=300 fill="rgba(200,0,0,0.5)" />
    return <g>{previousMarks}</g>

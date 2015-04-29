# @cjsx React.DOM

React                         = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
SVGImage                      = require './svg-image'
Draggable                     = require '../lib/draggable'
LoadingIndicator              = require './loading-indicator'
SubjectMetadata               = require './subject-metadata'
ActionButton                  = require './action-button'
markingTools                  = require './mark/tools'

RowFocusTool                  = require 'components/row-focus-tool'


module.exports = React.createClass
  displayName: 'SubjectViewer'
  resizing: false

  getInitialState: ->
    console.log "setting initial state: #{@props.active}"

    imageWidth: 0
    imageHeight: 0

    subject: @props.subject
    classification: null

    tool: @props.tool
    marks: []
    selectedMark: null
    lastMarkKey: 0

    active: @props.active

  componentDidMount: ->
    @setView 0, 0, @state.imageWidth, @state.imageHeight
    @loadImage @state.subject.location.standard
    window.addEventListener "resize", this.updateDimensions

  componentWillMount: ->
    @updateDimensions()

  componentWillUnmount: ->
    window.removeEventListener "resize", this.updateDimensions

  updateDimensions: ->
    @setState
      windowInnerWidth: window.innerWidth
      windowInnerHeight: window.innerHeight

  loadImage: (url) ->
    @setState loading: true, =>
      img = new Image()
      img.src = url
      # console.log 'URL: ', url
      img.onload = =>
        if @isMounted()
          @setState
            url: url
            imageWidth: img.width
            imageHeight: img.height
            loading: false, => console.log 'URL: ', url
              #, => console.log 'url: ', url
            # console.log @state.loading
            # console.log "Finished Loading."

  # VARIOUS EVENT HANDLERS

  handleInitStart: (e) ->
    @props.annotation["subject_id"] = @props.subject.id
    @props.annotation["workflow_id"] = @props.workflow.id

    taskDescription = @props.workflow.tasks[@props.annotation.task]

    # setting flag for generation of new subjects
    if @props.workflow.tasks[@props.annotation.task].generate_subjects
      @props.annotation["generate_subjects"] = @props.workflow.tasks[@props.annotation.task].generate_subjects

    mark = @state.selectedMark

    markIsComplete = true
    if mark?
      toolDescription = taskDescription.tools[mark.tool]
      MarkComponent = markingTools[toolDescription.type]
      if MarkComponent.isComplete?
        markIsComplete = MarkComponent.isComplete mark

    mouseCoords = @getEventOffset e

    # DEBUG CODE
    # console.log 'PROPS.ANNOTATION: ', @props.annotation

    if markIsComplete
      toolDescription = taskDescription.tools[@props.annotation._toolIndex]
      mark =
        key: @state.lastMarkKey
        tool: @props.annotation._toolIndex
        toolName: taskDescription.tools[@props.annotation._toolIndex].type

      if toolDescription.details?
        mark.details = for detailTaskDescription in toolDescription.details
          # DEBUG CODE
          #console.log "!taskTacking", tasks[detailTaskDescription.type]
          tasks[detailTaskDescription.type].getDefaultAnnotation()

    @props.annotation.value.push mark
    @selectMark @props.annotation, mark

    MarkComponent = markingTools[toolDescription.type]

    if MarkComponent.defaultValues?
      defaultValues = MarkComponent.defaultValues mouseCoords
      for key, value of defaultValues
        mark[key] = value

    if MarkComponent.initStart?
      initValues = MarkComponent.initStart mouseCoords, mark, e
      for key, value of initValues
        mark[key] = value

    @setState lastMarkKey: @state.lastMarkKey + 1

    setTimeout =>
      @updateAnnotations()

  handleInitDrag: (e) ->
    task = @props.workflow.tasks[@props.annotation.task]
    mark = @state.selectedMark
    MarkComponent = markingTools[task.tools[mark.tool].type]
    if MarkComponent.initMove?
      mouseCoords = @getEventOffset e
      initMoveValues = MarkComponent.initMove mouseCoords, mark, e
      for key, value of initMoveValues
        mark[key] = value
    @updateAnnotations()

  handleInitRelease: (e) ->
    task = @props.workflow.tasks[@props.annotation.task]
    mark = @state.selectedMark
    MarkComponent = markingTools[task.tools[mark.tool].type]
    if MarkComponent.initRelease?
      mouseCoords = @getEventOffset e
      initReleaseValues = MarkComponent.initRelease mouseCoords, mark, e
      for key, value of initReleaseValues
        mark[key] = value
    @updateAnnotations()
    if MarkComponent.initValid? and not MarkComponent.initValid mark
      @destroyMark @props.annotation, mark

  setView: (viewX, viewY, viewWidth, viewHeight) ->
    @setState {viewX, viewY, viewWidth, viewHeight}

  getScale: ->
    rect = @refs.sizeRect?.getDOMNode().getBoundingClientRect()
    rect ?= width: 0, height: 0
    horizontal = rect.width / @state.imageWidth
    vertical = rect.height / @state.imageHeight
    return {horizontal, vertical}

  getEventOffset: (e) ->
    rect = @refs.sizeRect.getDOMNode().getBoundingClientRect()
    scale = @getScale()
    x = ((e.pageX - pageXOffset - rect.left) / scale.horizontal) + @state.viewX
    y = ((e.pageY - pageYOffset - rect.top) / scale.vertical) + @state.viewY
    return {x, y}

  onClickDelete: (key) ->
    marks = @state.marks
    for mark, i in [ marks...]
      if mark.key is key
        marks.splice(i,1) # delete marks[key]
    @setState
      marks: marks
      selectedMark: null, =>
        @forceUpdate() # make sure keys are up-to-date

  handleMarkClick: (mark, e) ->
    { x, y } = @getEventOffset e
    @setState
      selectedMark: mark
      clickOffset:
        x: mark.x - x
        y: mark.y - y
      # , => @forceUpdate()

  selectMark: (annotation, mark) ->
    if annotation? and mark?
      index = annotation.value.indexOf mark
      annotation.value.splice index, 1
      annotation.value.push mark
    @setState selectedMark: mark, =>
      if mark?.details?
        @forceUpdate() # Re-render to reposition the details tooltip.
    console.log 'leaving selectMark()...'

  destroyMark: (annotation, mark) ->
    if mark is @state.selectedMark
      @setState selectedMark: null
    markIndex = annotation.value.indexOf mark
    annotation.value.splice markIndex, 1
    @updateAnnotations()

  updateAnnotations: ->
    @props.classification.update 'annotations'
    @forceUpdate()

  render: ->
    # return null if @state.subjects is null or @state.subjects.length is 0
    # return null unless @state.subject?
    # console.log 'SUBJECT: ', @state.subject

    viewBox = [0, 0, @state.imageWidth, @state.imageHeight]
    ToolComponent = @state.tool

    # DEBUG CODE
    # console.log "Rendering #{if @props.active then 'active' else 'inactive'} subj viewer"

    scale = @getScale()

    actionButton =
      if @state.loading
        <ActionButton onAction={@nextSubject} className="disabled" text="Loading..." />
      else
        <ActionButton onClick={@nextSubject} text="Next Page" />

    if @state.loading
      markingSurfaceContent = <LoadingIndicator />
    else
      markingSurfaceContent =
        <svg
          className = "subject-viewer-svg"
          width = {@state.imageWidth}
          height = {@state.imageHeight}
          viewBox = {viewBox}
          data-tool = {@props.selectedDrawingTool?.type} >
          <rect
            ref = "sizeRect"
            width = {@state.imageWidth}
            height = {@state.imageHeight} />
          <Draggable
            onStart = {@handleInitStart}
            onDrag  = {@handleInitDrag}
            onEnd   = {@handleInitRelease} >
            <SVGImage
              src = {@state.subject.location.standard}
              width = {@state.imageWidth}
              height = {@state.imageHeight} />
          </Draggable>

          { for annotation in @props.classification.annotations
              annotation._key ?= Math.random()
              isPriorAnnotation = annotation isnt @props.annotation
              taskDescription = @props.workflow.tasks[annotation.task]

              if taskDescription.tool is 'drawing'
                <g key={annotation._key} className="marks-for-annotation" data-disabled={isPriorAnnotation or null}>
                  {for mark, m in annotation.value

                    console.log 'ANNOTATION VALUE: ', annotation.value

                    mark._key ?= Math.random()
                    toolDescription = taskDescription.tools[mark.tool]

                    #adds task and description to each annotation
                    @props.annotation["tool_task_description"] = @props.workflow.tasks[annotation.task].tools[mark.tool]
                    console.log 'TOOL TASK DESCRIPTION: ', @props.annotation["tool_task_description"]
                    ToolComponent = markingTools[toolDescription.type]

                    <ToolComponent
                      key={mark._key}
                      mark={mark}
                      xScale={scale.horizontal}
                      yScale={scale.vertical}
                      disabled={isPriorAnnotation}
                      selected={mark is @state.selectedMark}
                      getEventOffset={@getEventOffset}
                      ref={@refs.sizeRect}

                      onChange={@updateAnnotations}
                      onSelect={@selectMark.bind this, annotation, mark}
                      onDestroy={@destroyMark.bind this, annotation}
                    />
                  }
                </g>
            }

            { # ROW FOCUS TOOL -------------------------------------------
              if @props.workflow.name is "transcribe" and @state.subject.location.spec.toolName is "textRowTool"
                console.log 'ROW TOOL!'
                markHeight = @state.subject.location.spec.yLower - @state.subject.location.spec.yUpper
                <g>

                  <rect
                    className   = "mark-rectangle"
                    x           = 0
                    y           = { 0 }
                    width       = { @state.imageWidth }
                    height      = { @state.subject.location.spec.yUpper }
                    fill        = "rgba(0,0,0,0.6)"
                  />

                  <rect
                    className   = "mark-rectangle"
                    x           = 0
                    y           = { @state.subject.location.spec.yLower }
                    width       = { @state.imageWidth }
                    height      = { @state.imageHeight - @state.subject.location.spec.yLower }
                    fill        = "rgba(0,0,0,0.6)"
                  />
                </g>
            }


            { # RECTANGLE FOCUS TOOL ------------------------------------------
              if @props.workflow.name is "transcribe" and @state.subject.location.spec.toolName is "rectangleTool"
                console.log 'RECTANGLE TOOL!'
                markHeight = @state.subject.location.spec.yLower - @state.subject.location.spec.yUpper
                <g>

                  <rect
                    className   = "mark-rectangle top"
                    x           = 0
                    y           = 0
                    width       = { @state.imageWidth }
                    height      = { @state.subject.location.spec.y }
                    fill        = "rgba(0,0,0,0.6)"
                  />

                  <rect
                    className   = "mark-rectangle bottom"
                    x           = 0
                    y           = { @state.subject.location.spec.y + @state.subject.location.spec.height }
                    width       = { @state.imageWidth }
                    height      = { @state.imageHeight - @state.subject.location.spec.y + @state.subject.location.spec.height }
                    fill        = "rgba(0,0,0,0.6)"
                  />

                  <rect
                    className   = "mark-rectangle left"
                    x           = 0
                    y           = { @state.subject.location.spec.y }
                    width       = { @state.subject.location.spec.x }
                    height      = { @state.subject.location.spec.height }
                    fill        = "rgba(0,0,0,0.6)"
                  />

                  <rect
                    className   = "mark-rectangle right"
                    x           = { @state.subject.location.spec.x + @state.subject.location.spec.width}
                    y           = { @state.subject.location.spec.y }
                    width       = { @state.imageWidth - @state.subject.location.spec.width - @state.subject.location.spec.x }
                    height      = { @state.subject.location.spec.height }
                    fill        = "rgba(0,0,0,0.6)"
                  />

                </g>
            }

          </svg>

    <div className="subject-viewer#{if @props.active then ' active' else ''}">
      <div className="subject-container">
        <div className="marking-surface">
          {markingSurfaceContent}
        </div>
      </div>
    </div>

window.React = React

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

MarkDrawingMixin              = require 'lib/mark-drawing-mixin'

API = require "lib/api"


module.exports = React.createClass
  displayName: 'SubjectViewer'
  resizing: false

  mixins: [MarkDrawingMixin] # load helper methods to draw marks and highlights

  getInitialState: ->
    # console.log "setting initial state: #{@props.active}"

    imageWidth: 0
    imageHeight: 0

    subject: @props.subject
    classification: null

    tool: @props.tool
    marks: []
    selectedMark: null
    lastMarkKey: 0

    active: @props.active


  getDefaultProps: ->
    tool: null # Optional tool to place alongside subject (e.g. transcription tool placed alongside mark)
    onLoad: null
    annotationIsComplete: false

  componentDidMount: ->
    @setView 0, 0, @state.imageWidth, @state.imageHeight
    @loadImage @props.subject.location.standard
    window.addEventListener "resize", this.updateDimensions

  componentWillMount: ->
    # @updateDimensions()

  componentWillUnmount: ->
    window.removeEventListener "resize", this.updateDimensions

  updateDimensions: ->
    @setState
      windowInnerWidth: window.innerWidth
      windowInnerHeight: window.innerHeight

    # console.log "if ! ", @state.loading, @getScale(), @props.onResize
    if ! @state.loading && @getScale()? && @props.onLoad?
      scale = @getScale()
      props =
        size:
          w: scale.horizontal * @state.imageWidth
          h: scale.vertical * @state.imageHeight
          scale: scale

      @props.onLoad props

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
            loading: false
          @updateDimensions()

  # VARIOUS EVENT HANDLERS

  handleInitStart: (e) ->
    console.log 'handleInitStart()'
    return null if ! @props.annotation? || ! @props.annotation.task?

    @props.annotation["subject_id"] = @props.subject.id
    @props.annotation["workflow_id"] = @props.workflow.id

    taskDescription = @props.workflow.tasks[@props.annotation.task]

    console.log 'ANNOTATION AT BEGINNING OF HANDLE INIT START: ', @props.annotation

    console.log 'TASK DESCRIPTION: ', taskDescription

    # setting flag for generation of new subjects
    if @props.workflow.tasks[@props.annotation.task].generate_subjects
      @props.annotation["generate_subjects"] = @props.workflow.tasks[@props.annotation.task].generate_subjects

    annotation = @props.annotation #@state.selectedMark
    @props.annotationIsComplete = true

    # if mark?
    #   toolDescription = taskDescription.tools[mark.tool]
    #   MarkComponent = markingTools[toolDescription.type]
    #   if MarkComponent.isComplete?
    #     annotationIsComplete = MarkComponent.isComplete mark

    mouseCoords = @getEventOffset e

    if @props.annotationIsComplete
      toolDescription = taskDescription.tools[@props.annotation._toolIndex]
      # mark =
      annotation.key       = @state.lastMarkKey
      annotation.toolIndex = @props.annotation._toolIndex
      annotation.toolName  = taskDescription.tools[@props.annotation.toolIndex].type
        #
        # key:      @state.lastMarkKey
        # tool:     @props.annotation._toolIndex
        # toolName: taskDescription.tools[@props.annotation._toolIndex].type
        # task:     @props.workflow #FIX!

      if toolDescription.details?
        annotation.details = for detailTaskDescription in toolDescription.details
          # DEBUG CODE
          #console.log "!taskTacking", tasks[detailTaskDescription.type]
          tasks[detailTaskDescription.type].getDefaultAnnotation()

    # @props.annotation = mark
    @selectMark @props.annotation

    MarkComponent = markingTools[toolDescription.type]

    if MarkComponent.defaultValues?
      defaultValues = MarkComponent.defaultValues mouseCoords
      for key, value of defaultValues
        annotation[key] = value

    if MarkComponent.initStart?
      initValues = MarkComponent.initStart mouseCoords, annotation, e
      for key, value of initValues
        annotation[key] = value

    @setState lastMarkKey: @state.lastMarkKey + 1

    setTimeout =>
      @updateAnnotations()

  handleInitDrag: (e) ->
    console.log 'handleInitDrag()'
    task = @props.workflow.tasks[@props.annotation.task]
    mark = @props.annotation #@state.selectedMark
    # console.log "SubjectViewer#handleInitDrag"
    MarkComponent = markingTools[mark.toolName]
    if MarkComponent.initMove?
      mouseCoords = @getEventOffset e
      initMoveValues = MarkComponent.initMove mouseCoords, mark, e
      for key, value of initMoveValues
        mark[key] = value
    @updateAnnotations()

  handleInitRelease: (e) ->
    return null if ! @props.annotation? || ! @props.annotation.task?
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

  # PB This is not returning anything but 0, 0 for me; Seems like @refs.sizeRect is empty when evaluated (though nonempty later)
  getScale: ->
    rect = @refs.sizeRect?.getDOMNode().getBoundingClientRect()
    rect ?= width: 0, height: 0
    horizontal = rect.width / @state.imageWidth
    vertical = rect.height / @state.imageHeight
    # TODO hack fallback:
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

  selectMark: (annotation) ->
    return # this will be broken for now -- STI
    if annotation? and mark?
      index = annotation.value.indexOf mark
      annotation.value.splice index, 1
      annotation.value.push mark
    @setState selectedMark: mark, =>
      if mark?.details?
        @forceUpdate() # Re-render to reposition the details tooltip.

  destroyMark: (annotation) ->
    console.log 'destroyMark(): annotation: ', annotation
    annotation = null
    return

    if mark is @state.selectedMark
      @setState selectedMark: null
    markIndex = annotation.value.indexOf mark
    annotation.value.splice markIndex, 1
    @updateAnnotations()

  updateAnnotations: ->
    # @props.classification.update 'annotations'
    @props.classification.update 'annotation'
    @forceUpdate()

  submitMark: (mark) ->
    metadata =
      started_at: (new Date).toISOString() # this is dummy
      finished_at: (new Date).toISOString()

    # # SUBMITT MARK VIA JSON-API-CLIENT (PROBLEMS WITH RETRIEVING RESPONSE)
    # classification = API.type('classifications').create
    #   name:        'Classification'
    #   subject_id:  @props.subject.id
    #   workflow_id: @props.workflow.id
    #   annotations: []
    #   metadata:    metadata
    #
    # classification.annotations.push @props.annotation
    # classification.update 'annotations'
    # classification.save() # submit classification

    # PREPARE CLASSIFICATION TO SEND
    classification =
      classifications:
        name:        'Classification'

        subject_id:  @props.subject.id
        workflow_id: @props.workflow.id
        annotation:  @props.annotation
        metadata:    metadata

    console.log '(SINGLE) CLASSIFICATION: ', classification

    $.ajax({
      type:        'post'
      url:         '/classifications'
      data:        JSON.stringify(classification)
      dataType:    'json'
      contentType: 'application/json'
      })
      .done (response) =>
        console.log "Success" #, #response #, response._id.$oid
        console.log 'RECEIVED SECONDARY SUBJECT ID: ', response.child_subject_id
        console.log 'SELECTED MARK: ', @state.selectedMark
        # @setTranscribeSubject(key, response._id.$oid)
        # @enableMarkButton(key)
        return
      .fail =>
        console.log "Failure"
        return
      .always ->
        console.log "Always"
        return

  render: ->
    console.log 'SUBJECT-VIEWER::render()  CURRENT ANNOTATION: ', @props.annotation



    # return null if @props.subjects is null or @props.subjects.length is 0
    # return null unless @props.subject?
    # console.log 'SUBJECT: ', @props.subject

    viewBox = [0, 0, @state.imageWidth, @state.imageHeight]
    ToolComponent = @state.tool
    # console.log "Rendering #{if @props.active then 'active' else 'inactive'} subj viewer"

    scale = @getScale()
    renderSize = {w: scale.horizontal * @state.imageWidth, h: scale.vertical * @state.imageHeight}
    holderStyle =
      width: "#{renderSize.w}px"
      height: "#{renderSize.h}px"

    actionButton =
      if @state.loading
        <ActionButton onAction={@nextSubject} className="disabled" text="Loading..." />
      else
        <ActionButton onClick={@nextSubject} text="Next Page" />

    # console.log "SubjectViewer#render: render subject with mark? ", @props.subject

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
              src = {@props.subject.location.standard}
              width = {@state.imageWidth}
              height = {@state.imageHeight} />
          </Draggable>

          { # DISPLAY PREVIOUS MARKS
            # null
            # COMMENT FOR NOW -- STI
            # for mark, i in @props.subject.child_subjects_info
            #   toolName = mark.data.toolName
            #   ToolComponent = markingTools[toolName]
            #   scale = @getScale()

            #   console.log 'REFS: ', @refs

            #   <ToolComponent
            #     key={i}
            #     mark={mark.data}
            #     xScale={scale.horizontal}
            #     yScale={scale.vertical}
            #     disabled={true}
            #     isPriorMark={true}
            #     selected={false}
            #     getEventOffset={@getEventOffset}
            #     ref={@refs.sizeRect}

            #     onChange={=> console.log 'ON CHANGE'}
            #     onSelect={=> console.log 'ON SELECT'}
            #     onDestroy={=> console.log 'ON DESTORY'}
            #   />


            # THIS IS CAUSING PROBLEMS - STI
            if @props.workflow.name is 'mark'
              @showPreviousMarks()
              # @showTranscribeTools()
          }

          { # HIGHLIGHT SUBJECT FOR TRANSCRIPTION
            # TODO: Makr sure x, y, w, h are scaled properly

            if @props.workflow.name is 'transcribe'
              console.log "props in subject viewer", @props
              console.log @props.subject
              toolName = @props.subject.data.toolName
              mark = @props.subject.data
              ToolComponent = markingTools[toolName]
              isPriorMark = true
              <g>
                { @highlightMark(mark, toolName) }
                <ToolComponent
                  key={@props.subject.id}
                  mark={mark}
                  xScale={scale.horizontal}
                  yScale={scale.vertical}
                  disabled={isPriorMark}
                  selected={mark is @state.selectedMark}
                  getEventOffset={@getEventOffset}
                  ref={@refs.sizeRect}
                  onSelect={@selectMark.bind this, @props.subject, mark}
                />
              </g>
          }

          { # TODO: ANNOTATIONS SHOULD NOT BE AN ARRAY
            # DISPLAY CURRENT ANNOTATION (MARK)
            # for annotation in @props.classification.annotations
            if @props.workflow.name is 'transcribe'

              annotation = @props.annotation

              annotation._key ?= Math.random()
              isPriorMark = annotation isnt @props.annotation

              # taskDescription = @props.workflow.tasks[annotation.task]

              if @props.subject.region.toolName is 'pickOneMarkOne' and @props.annotationIsComplete #or taskDescription.tool is 'transcribe'
                <g key={annotation._key} className="marks-for-annotation" data-disabled={isPriorMark or null}>
                  {

                    #for mark, m in annotation.value

                    # mark._key ?= Math.random()
                    # toolDescription = taskDescription.tools[annotation.tool]

                    # console.log 'WORKFLOW: ', @props.workflow.tasks[annotation.task].tools

                    #adds task and description to each annotation
                    @props.annotation["tool_task_description"] = @props.workflow.tasks[annotation.task].tools[annotation.toolIndex]
                    @props.annotation["generated_subject_type"] = @props.workflow.tasks[annotation.task].tools[annotation.toolIndex].generated_subject_type
                    ToolComponent = markingTools[@props.annotation.toolName]

                    <ToolComponent
                      key={annotation._key}
                      mark={annotation}
                      xScale={scale.horizontal}
                      yScale={scale.vertical}
                      disabled={false}
                      isPriorMark={isPriorMark}
                      selected={true}
                      getEventOffset={@getEventOffset}
                      ref={@refs.sizeRect}
                      submitMark={@submitMark}

                      onChange={@updateAnnotations}
                      onSelect={@selectMark.bind this, annotation, mark}
                      onDestroy={@destroyMark.bind this, annotation}
                    />
                  }
                </g>
            }
          </svg>

    #  Render any tools passed directly in in same parent div so that we can efficiently position them with respect to marks"

    <div className="subject-viewer#{if @props.active then ' active' else ''}">
      <div className="subject-container">
        <div className="marking-surface">
          {markingSurfaceContent}
          {@props.children}
        </div>
      </div>
    </div>

window.React = React

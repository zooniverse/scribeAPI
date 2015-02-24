# @cjsx React.DOM
React         = require 'react'
SubjectViewer = require '../subject-viewer'

module.exports = React.createClass
  displayName: 'Transcribe'

  getInitialState: ->
    # TODO: why is workflow an array!?!?
    workflow: @props.workflow


  componentWillMount: ->
    workflow = @state.workflow
    currentTask = workflow.tasks[ workflow.first_task ]

    if @state.firstTask?
      @setState
        currentTask: currentTask
        currentTool: currentTask.tool , =>
          console.log 'first tool is: ', @state.currentTool
      
  render: ->
    <SubjectViewer endpoint=endpoint workflow={@props.workflow} />

window.React = React

# SubjectViewer = React.createClass
#   displayName: 'SubjectViewer'
#   resizing: false

#   getInitialState: ->
#     console.log 'getInitialState()'
#     scrollOffset: getUrlParamByName 'scrollOffset'
#     subjects: null
#     subject: null
#     subjectEndpoint: @props.endpoint
#     resizeDisabled: true
#     marks: []
#     tools: []
#     loading: true
#     frame: 0
#     imageWidth: 0
#     imageHeight: 0
#     viewX: 0
#     viewY: 0
#     viewWidth: 0
#     viewHeight: 0
#     classification: null
#     selectedMark: null # TODO: currently not in use
#     showTranscribeTool: true
#     yScale: null
#     xScale: null

#   componentDidMount: ->
#     console.log 'componentDidMount()'
#     @setView 0, 0, @state.imageWidth, @state.imageHeight

#     @fetchSubjects(@state.subjectEndpoint)
#     window.addEventListener "resize", this.updateDimensions

#     # scroll to mark position
#     $('html, body').animate { 'scrollTop': @state.scrollOffset }, 200, 'swing'

#   componentWillMount: ->
#     console.log 'componentWillMount()'
#     @updateDimensions()

#   componentDidUpdate: ->
#     # console.log 'componentWillUpdate(): ', @state
#     # console.log 'getScale: ', @getScale()
#     # console.log 'shouldComponentUpdate() = '

#   componentWillUnmount: ->
#     window.removeEventListener "resize", this.updateDimensions

#   updateDimensions: ->
#     @setState
#       windowInnerWidth: window.innerWidth
#       windowInnerHeight: window.innerHeight

#   fetchSubjects: (endpoint) ->
#     $.ajax
#       url: endpoint
#       dataType: "json"
#       success: ((data) ->
#         # # DEBUG CODE
#         # console.log 'FETCHED SUBJECTS: ', data

#         @setState
#           subject:      data
#           marks:        data.annotations
#           selectedMark: data.annotations[0], =>
#             # DEBUG CODE
#             # console.log 'SUBJECT: ', @state.subject
#             # console.log 'marks: ', @state.marks
#             # console.log 'selectedMark: ', @state.selectedMark
#             @state.classification = new Classification @state.subject
#             @loadImage @state.subject.location

#           # subjects:     data
#           # subject:      data[0].subject
#           # marks:        data[0].subject.annotations
#           # selectedMark: data[0].subject.annotations[0], =>
#           #   # console.log 'MARKS: ', @state.marks
#           #   @state.classification = new Classification @state.subject
#           #   @loadImage @state.subject.location

#         return
#       ).bind(this)
#       error: ((xhr, status, err) ->
#         console.error "Error loading subjects: ", @props.endpoint, status, err.toString()
#         return
#       ).bind(this)
#     return

#   loadImage: (url) ->
#     # console.log 'Loading image... ', url # DEBUG CODE
#     @setState loading: true, =>
#       img = new Image()
#       img.src = url
#       img.onload = =>
#         # if @isMounted()
#         @setState
#           url: url
#           imageWidth: img.width
#           imageHeight: img.height
#           loading: false, =>
#             @setState # ugh, this sucks
#               xScale: @getScale().horizontal
#               yScale: @getScale().vertical, =>
#                 @forceUpdate() # kill me now...

#   nextSubject: () ->
#     console.log 'nextSubject()'

#     return # disable for now

#     # TODO: annotate new transcription and submit as new classification!!!
#     @setState showTranscribeTool: true

#     for mark in [ @state.marks... ]
#       if mark.transcription isnt undefined
#         @state.classification.annotate
#           timestamp: mark.timestamp
#           transcription: mark.transcription

#     # DEBUG CODE
#     # console.log 'CLASSIFICATION: ', @state.classification
#     # console.log JSON.stringify @state.classification # DEBUG CODE
#     # @state.classification.send()

#     @setState
#       marks: [] # clear marks for next subject

#     @resetTranscriptionFields()

#     # prepare new classification
#     if @state.subjects.shift() is undefined or @state.subjects.length <= 0
#       @fetchSubjects(@state.subjectEndpoint)
#       return
#     else
#       @setState subject: @state.subjects[0], =>
#         @loadImage @state.subject.location

#     @state.classification = new Classification @state.subject

#   # EVENT HANDLERS (CURRENTLY NOT IN USE)

#   handleInitStart: (e) ->
#     # console.log 'handleInitStart()'
#     return # don't do anything

#   handleInitDrag: (e) ->
#     # console.log 'handleInitDrag()'
#     return # don't do anything

#   handleInitRelease: (e) ->
#     # console.log 'handleInitRelease()'
#     return # don't do anything

#   handleToolMouseDown: ->
#     # console.log 'handleToolMouseDown()'
#     return # don't do anything

#   handleMarkClick: (mark, e) ->
#     # console.log 'handleMarkClick()'
#     return # don't do anything

#   handleDragMark: (e) ->
#     # console.log 'handleDragMark()'
#     return # don't do anything

#   handleUpperResize: (e) ->
#     # console.log 'handleUpperResize()'
#     return # don't do anything

#   handleLowerResize: (e) ->
#     # console.log 'handleLowerResize()'
#     return # don't do anything

#   setView: (viewX, viewY, viewWidth, viewHeight) ->
#     @setState {viewX, viewY, viewWidth, viewHeight}

#   getScale: ->
#     rect = @refs.sizeRect?.getDOMNode().getBoundingClientRect()
#     rect ?= width: 0, height: 0

#     horizontal: rect.width / @state.imageWidth
#     vertical: rect.height / @state.imageHeight

#   getEventOffset: (e) ->
#     rect = @refs.sizeRect.getDOMNode().getBoundingClientRect()
#     {horizontal, vertical} = @getScale()
#     x: ((e.pageX - pageXOffset - rect.left) / horizontal) + @state.viewX
#     y: ((e.pageY - pageYOffset - rect.top) / vertical) + @state.viewY

#   selectMark: (mark) ->
#     return if mark is @state.selectedMark
#     @setState selectedMark: mark

#   onClickDelete: (key) ->
#     marks = @state.marks
#     for mark, i in [ marks... ]
#       if mark.key is key
#         marks.splice(i, 1)
#     @setState
#       marks: marks
#       selectedMark: null

#   recordTranscription: (transcription) ->
#     selectedMark = @state.selectedMark
#     selectedMark.transcription = transcription
#     @setState selectedMark: selectedMark #, =>
#       # console.log 'SELECTED MARK: ', @state.selectedMark

#   resetTranscriptionFields: ->
#     # console.log 'resetTranscriptionFields()'
#     $('.transcribe-input').val("")

#   beginTextEntry: ->
#     return unless @state.marks.length > 0
#     @setState
#       selectedMark: @state.marks[0], =>
#         {horizontal, vertical} = @getScale()
#         $('html, body').animate scrollTop: vertical*@state.selectedMark.y-window.innerHeight/2+80, 500

#   nextTextEntry: ->
#     console.log 'nextTextEntry() '
#     @forceUpdate()
#     return # disable for now

#     # console.log 'STATE.SELECTEDMARK.KEY: ', @state.selectedMark.key
#     # console.log 'STATE.MARKS.LENGTH: ', @state.marks.length

#     # hide transcribe-tool unless more text entries available
#     if @state.selectedMark.key + 1 > @state.marks.length - 1
#       @setState showTranscribeTool: false
#       return

#     key = @state.selectedMark.key

#     # if key > @state.marks.length - 1
#     #   console.log 'NO MORE MARKS'
#     @setState
#       selectedMark: @state.marks[key+1], =>
#         {horizontal, vertical} = @getScale()
#         $('html, body').animate scrollTop: vertical*@state.selectedMark.y-window.innerHeight/2+80, 500

#     @resetTranscriptionFields()

#     # console.log 'KEY : ', key
#     # console.log 'LENGTH: ', @state.marks.length - 1

#     if key+2 > @state.marks.length
#       # console.log 'NO MORE MARKS'
#       return false
#     return true

#   # DEBUG SUBJECT EXAMPLE "https://zooniverse-static.s3.amazonaws.com/scribe_subjects/logbookofalfredg1851unse_0083.jpg"

#   render: ->
#     # console.log 'render()'

#     # return null if @state.selectedMark is null
#     # don't render if ya ain't got subjects (yet)

#     return null unless @state.selectedMark?

#     # return null unless @state.subject isnt null
#     # return null if @state.subjects is null or @state.subjects.length is 0

#     viewBox = [0, 0, @state.imageWidth, @state.imageHeight]

#     # LOADING
#     if @state.loading
#       <div className="subject-container">
#         <div className="marking-surface">
#           <LoadingIndicator/>
#         </div>
#         <p>{ @state.subject.location }</p>
#         <div className="subject-ui">
#           <ActionButton loading={@state.loading} />
#         </div>
#       </div>

#     else

#       if @state.selectedMark.key is @state.marks.length - 1 # we're done
#         action_button = <ActionButton label={"NEXT PAGE"} onActionSubmit={@nextSubject} />
#       else
#         action_button = <ActionButton label={"NEXT"} onActionSubmit={@nextTextEntry} />

#       <div className="subject-container">
#         <div className="marking-surface">

#           <svg
#             className = "subject-viewer-svg"
#             width = {@state.imageWidth}
#             height = {@state.imageHeight}
#             viewBox = {viewBox}
#             data-tool = {@props.selectedDrawingTool?.type} >

#             <rect
#               ref = "sizeRect"
#               width = {@state.imageWidth}
#               height = {@state.imageHeight} />

#             <Draggable
#               onStart = {@handleInitStart}
#               onDrag  = {@handleInitDrag}
#               onEnd   = {@handleInitRelease} >
#               <SVGImage
#                 src = {@state.subject.location}
#                 width = {@state.imageWidth}
#                 height = {@state.imageHeight} />
#             </Draggable>

#             <RowFocusTool 
#               key = {@state.selectedMark.key}
#               mark = {@state.selectedMark}
#               disabled = {false}
#               imageWidth = { @state.imageWidth}
#               imageHeight = { Math.round(@state.imageHeight) }
#               getEventOffset = {@getEventOffset}
#               select = {@selectMark.bind null, @state.selectedMark}
#               selected = {true}
#               onClickDelete = {@onClickDelete}
#               scrubberWidth = {64}
#               scrubberHeight = {32}
#               resizeDisabled = {@state.resizeDisabled}
#               handleDragMark = {@handleDragMark}
#               handleUpperResize = {@handleUpperResize}
#               handleLowerResize = {@handleLowerResize}
#               handleMarkClick = {@handleMarkClick.bind null, @state.selectedMark}
#             />

#           </svg>

#           { if @state.showTranscribeTool and not @state.loading
#               <TranscribeTool
#                 tasks={@props.tasks}
#                 recordTranscription={@recordTranscription}
#                 nextTextEntry={@nextTextEntry}
#                 nextSubject = {@nextSubject}
#                 selectedMark={@state.selectedMark}
#                 xScale={@state.xScale}
#                 yScale={@state.yScale}
#                 scrollOffset={@state.scrollOffset}
#               />
#           }

#         </div>
#         <div className="subject-ui">
#           {action_button}
#         </div>
#       </div>

# module.exports = ImageSubjectViewer_transcribe
# window.React = React

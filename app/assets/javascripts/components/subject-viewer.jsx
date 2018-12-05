/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import ReactDOM from 'react-dom'
import createReactClass from 'create-react-class'

import SVGImage from './svg-image.jsx'
import MouseHandler from '../lib/mouse-handler.jsx'
import LoadingIndicator from './loading-indicator.jsx'
import NextButton from './action-button.jsx'
import markingTools from './mark/tools/index.jsx'
import MarkDrawingMixin from '../lib/mark-drawing-mixin.jsx'

export default createReactClass({
  displayName: 'SubjectViewer',
  resizing: false,

  mixins: [MarkDrawingMixin], // load helper methods to draw marks and highlights

  getInitialState() {
    return {
      subject: this.props.subject,
      marks: this.getMarksFromProps(this.props),
      selectedMark: null,
      active: this.props.active,
      zoom: {
        level: 1,
        x: 0,
        y: 0
      },
      scale: { horizontal: 1, vertical: 1, offsetX: 0, offsetY: 0 },
      sameSessionTranscriptions: []
    }
  },

  getDefaultProps() {
    return {
      tool: null, // Optional tool to place alongside subject (e.g. transcription tool placed alongside mark)
      onLoad: null,
      annotationIsComplete: false,
      interimMarks: {}
    }
  },

  componentWillReceiveProps(new_props) {
    if ((new_props.task != null ? new_props.task.tool : undefined) !== 'pickOneMarkOne') {
      this.setUncommittedMark(null)
    }

    if (Object.keys(this.props.annotation).length === 0) {
      //prevents back-to-back mark tasks, displaying a duplicate mark from previous tasks.
      this.setUncommittedMark(null)
    }

    this.setState({
      marks: this.getMarksFromProps(new_props)
    })

    if (new_props.subject.id === this.props.subject.id) {
      this.scrollToSubject()
    }
  },

  componentDidMount() {
    this.setView(0, 0, this.props.subject.width, this.props.subject.height)
    this.loadImage(this.props.subject.location.standard)
    window.addEventListener('resize', this.updateDimensions)
  },

  scrollToSubject() {
    // scroll to mark when transcribing
    if (this.props.workflow.name === 'transcribe') {
      const yPos =
        (this.props.subject.data.y - (this.props.subject.data.height != null)) *
        this.state.scale.vertical -
        100
      $('html, body')
        .stop()
        .animate({ scrollTop: yPos }, 500)
    }
  },

  componentDidUpdate() {
    const scale = this.getScale()
    const changed =
      scale.horizontal !== this.state.scale.horizontal &&
      scale.vertical !== this.state.scale.vertical
    if (changed) {
      this.setState({ scale }, () => {
        this.updateDimensions()
        this.scrollToSubject()
      })
    }
  },

  componentWillUnmount() {
    window.removeEventListener('resize', this.updateDimensions)
  },

  updateDimensions() {
    let props, scale
    if (!this.state.loading &&
      this.state.scale != null &&
      this.props.onLoad != null) {
      ({ scale } = this.state)
      props = {
        size: {
          w: scale.horizontal * this.props.subject.width,
          h: scale.vertical * this.props.subject.height
        }
      }

      this.props.onLoad(props)
    }

    // Fix for IE: On resize, manually set dims of svg because otherwise it displays as a tiny tiny thumb
    if ($('.subject-viewer')) {
      let w = parseInt($('.subject-viewer').width())
      w = Math.min(w, $('body').width() - 300)
      const h = (w / this.props.subject.width) * this.props.subject.height
      $('.subject-viewer svg').width(w)
      $('.subject-viewer svg').height(h)

      // Also a fix for IE:
      this.setState({ scale: this.getScale() })
    }
  },

  loadImage(url) {
    this.setState({ loading: true }, () => {
      const img = new Image()
      img.src = url
      img.onload = () => {
        this.setState(
          {
            url,
            loading: false,
            scale: this.getScale()
          },
          () => {
            this.updateDimensions()
            this.scrollToSubject()
          }
        )
      }
    })
  },

  // VARIOUS EVENT HANDLERS

  // Commit mark
  submitMark(mark) {
    if (mark == null) {
      return
    }
    if (typeof this.props.onComplete === 'function') {
      this.props.onComplete(mark)
    }
    this.setUncommittedMark(null)
  }, // reset uncommitted mark

  // Handle initial mousedown:
  handleInitStart(e) {
    if (e.buttons != null && e.button != null && e.button > 0) {
      return null
    } // ignore right-click
    const newMark = this.createMark(e)

    // Don't proceed as if a new mark was created if no mark was created (i.e. no drawing tool selected)
    if (newMark == null) {
      return
    }

    // submit uncommitted mark
    if (this.state.uncommittedMark != null) {
      this.submitMark(this.state.uncommittedMark)
    }

    if (typeof this.props.onChange === 'function') {
      this.props.onChange(newMark)
    }
    this.setUncommittedMark(newMark)
  },
  // @selectMark newMark

  createMark(e) {
    let key, subToolIndex, value
    if ((subToolIndex = this.props.subToolIndex) == null) {
      return null
    }
    let subTool = this.props.task.tool_config &&
      this.props.task.tool_config.options &&
      this.props.task.tool_config.options[subToolIndex]
    if (subTool == null) {
      return null
    }

    // Instantiate appropriate marking tool:
    const MarkComponent = markingTools[subTool.type] // NEEDS FIXING
    if (MarkComponent == null) {
      return null
    }
    const mark = {
      belongsToUser: true, // let users see their current mark when hiding others
      toolName: subTool.type,
      label: subTool.label,
      userCreated: true,
      subToolIndex,
      color: subTool.color, // @props.annotation?.subToolIndex
      isTranscribable: true // @props.annotation?.subToolIndex
    }

    const mouseCoords = this.getEventOffset(e)

    if (MarkComponent.defaultValues != null) {
      const defaultValues = MarkComponent.defaultValues(mouseCoords)
      for (key in defaultValues) {
        value = defaultValues[key]
        mark[key] = value
      }
    }

    // Gather initial coords from event into mark instance:
    if (MarkComponent.initStart != null) {
      const initValues = MarkComponent.initStart(mouseCoords, mark, e)
      for (key in initValues) {
        value = initValues[key]
        mark[key] = value
      }
    }

    return mark
  },

  // Handle mouse dragging
  handleInitDrag(e) {
    if (this.state.uncommittedMark == null) {
      return null
    }
    const mark = this.state.uncommittedMark
    const MarkComponent = markingTools[mark.toolName] // instantiate appropriate marking tool

    if (MarkComponent.initMove != null) {
      const mouseCoords = this.getEventOffset(e)
      const initMoveValues = MarkComponent.initMove(mouseCoords, mark, e)
      for (let key in initMoveValues) {
        const value = initMoveValues[key]
        mark[key] = value
      }
    }

    if (typeof this.props.onChange === 'function') {
      this.props.onChange(mark)
    }
    this.setState({ uncommittedMark: mark })
  },

  // Handle mouseup at end of drag:
  handleInitRelease(e) {
    if (this.state.uncommittedMark == null) {
      return null
    }

    const mark = this.state.uncommittedMark

    // Instantiate appropriate marking tool:
    // AMS: think this is going to markingTools[mark._toolIndex]
    const MarkComponent = markingTools[mark.toolName]

    if (MarkComponent.initRelease != null) {
      const mouseCoords = this.getEventOffset(e)
      const initReleaseValues = MarkComponent.initRelease(mouseCoords, mark, e)
      for (let key in initReleaseValues) {
        const value = initReleaseValues[key]
        mark[key] = value
      }
    }
    if (MarkComponent.initValid != null && !MarkComponent.initValid(mark)) {
      this.destroyMark(mark)
      return
    }

    mark.isUncommitted = true
    mark.belongsToUser = true
    this.setUncommittedMark(mark)
  },

  setUncommittedMark(mark) {
    return this.setState({
      uncommittedMark: mark,
      selectedMark: mark
    })
  }, //, => @forceUpdate() # not sure if this is needed?

  setView(viewX, viewY, viewWidth, viewHeight) {
    this.setState({ viewX, viewY, viewWidth, viewHeight })
  },

  // PB This is not returning anything but 0, 0 for me; Seems like @refs.sizeRect is empty when evaluated (though nonempty later)
  getScale() {
    let rect =
      this.refs.sizeRect != null
        ? ReactDOM.findDOMNode(this.refs.sizeRect).getBoundingClientRect()
        : undefined

    if (rect == null || rect.width == null) {
      return { horizontal: 1, vertical: 1, offsetX: 0, offsetY: 0 }
    }
    if (rect == null) {
      rect = { width: 0, height: 0 }
    }
    const horizontal = rect.width / this.props.subject.width
    const vertical = rect.height / this.props.subject.height
    const offsetX = rect.left + $(window).scrollLeft()
    const offsetY = rect.top + $(window).scrollTop()
    // PB: Adding offsetX and offsetY, which are also necessary to calculate window absolute px coordinates from source-image coordinates
    return { horizontal, vertical, offsetX, offsetY }
  },

  getEventOffset(e) {
    const rect = ReactDOM.findDOMNode(this.refs.sizeRect).getBoundingClientRect()
    const { scale } = this.state // @getScale()
    const x =
      (e.pageX - window.pageXOffset - rect.left) / scale.horizontal +
      this.state.viewX
    const y =
      (e.pageY - window.pageYOffset - rect.top) / scale.vertical +
      this.state.viewY
    return { x, y }
  },

  // Set mark to currently selected:
  selectMark(mark) {
    const sel = () => {
      return this.setState({ selectedMark: mark }, () => {
        if ((mark != null ? mark.details : undefined) != null) {
          this.forceUpdate()
        }
      }) // Re-render to reposition the details tooltip.
    }

    // First, if we're blurring some other uncommitted mark, commit it:
    if (this.state.uncommittedMark != null &&
      mark !== this.state.uncommittedMark) {
      this.submitMark(sel)
    } else {
      sel()
    }
  },

  // Destroy mark:
  destroyMark(mark) {
    const { marks } = this.state
    const ind = marks.indexOf(mark)

    // If it's a previously saved mark (by this or another user):
    if (ind >= 0) {
      // Submit flag to server:
      if (typeof this.props.onDestroy === 'function') {
        this.props.onDestroy(marks[ind])
      }

      // Flag the subject as deleted by user:
      marks[ind].user_has_deleted = true

      return this.setState({
        marks
      })
    } else if (mark === this.state.uncommittedMark) {
      this.props.destroyCurrentClassification()
    }
  },

  handleChange(mark) {
    this.setState({ selectedMark: mark }, () => {
      if (typeof this.props.onChange === 'function') {
        this.props.onChange(mark)
      }
    })
  },

  getMarksFromProps(props) {
    // Previous marks are really just the region hashes of all child subjects
    const marks = []
    const { currentSubtool } = props
    for (let i = 0; i < props.subject.child_subjects.length; i++) {
      const child_subject = props.subject.child_subjects[i]
      if (child_subject == null) {
        continue
      }
      marks[i] = child_subject.region
      marks[i].subject_id = child_subject.id // child_subject.region.subject_id = child_subject.id # copy id field into region (not ideal)
      marks[i].isTranscribable =
        !child_subject.user_has_classified &&
        child_subject.status !== 'retired'
      marks[i].belongsToUser = child_subject.belongs_to_user
      marks[i].groupActive =
        (currentSubtool != null
          ? currentSubtool.generates_subject_type
          : undefined) === child_subject.type
      marks[i].user_has_deleted = child_subject.user_has_deleted
    }

    // Also present visible 'interim mark's for this subject:
    for (let m of Array.from(
      this.props.interimMarks != null ? this.props.interimMarks : []
    )) {
      if (m.show && m.subject_id === props.subject.id) {
        marks.push(m)
      }
    }

    return marks
  },

  separateTranscribableMarks(marks) {
    const transcribableMarks = []
    const otherMarks = []
    for (let mark of Array.from(marks)) {
      if (mark.isTranscribable) {
        transcribableMarks.push(mark)
      } else {
        otherMarks.push(mark)
      }
    }

    return { transcribableMarks, otherMarks }
  },

  renderMarks(marks) {
    if (!(marks.length > 0)) {
      return
    }
    // scale = @getScale()
    const { scale } = this.state

    const marksToRender = (() => {
      const result = []
      for (let mark of Array.from(marks)) {
        var ToolComponent
        if (mark._key == null) {
          mark._key = Math.random()
        }
        if (mark.x == null || mark.y == null || mark.hide) {
          continue
        } // if mark hasn't acquired coords yet, don't draw it yet
        if (mark.user_has_deleted) {
          continue
        }

        if (this.props.hideOtherMarks) {
          if (!mark.belongsToUser) {
            continue
          }
        }

        const displaysTranscribeButton =
          (this.props.task != null
            ? this.props.task.tool_config.displays_transcribe_button
            : undefined) !== false
        const isPriorMark = !mark.userCreated

        result.push(
          <g
            key={mark._key}
            className={`marks-for-annotation${
              mark.groupActive ? ' group-active' : ''
            }`}
            data-disabled={isPriorMark || null}
          >
            {
              (mark._key != null ? mark._key : (mark._key = Math.random()),
              (ToolComponent = markingTools[mark.toolName]),
              (
                <ToolComponent
                  key={mark._key}
                  subject_id={mark.subject_id}
                  taskKey={
                    this.props.task != null ? this.props.task.key : undefined
                  }
                  mark={mark}
                  xScale={scale.horizontal}
                  yScale={scale.vertical}
                  disabled={!mark.userCreated}
                  isTranscribable={mark.isTranscribable}
                  interim={mark.interim_id != null}
                  isPriorMark={isPriorMark}
                  subjectCurrentPage={this.props.subjectCurrentPage}
                  selected={mark === this.state.selectedMark}
                  getEventOffset={this.getEventOffset}
                  submitMark={this.submitMark}
                  sizeRect={this.refs.sizeRect}
                  displaysTranscribeButton={displaysTranscribeButton}
                  onSelect={this.selectMark.bind(this, mark)}
                  onChange={this.handleChange.bind(this, mark)}
                  onDestroy={this.destroyMark.bind(this, mark)}
                />
              ))
            }
          </g>
        )
      }
      return result
    })()

    return marksToRender
  },

  render() {
    let markingSurfaceContent
    if (!this.props.active) {
      return null
    }

    const viewBox =
      this.props.viewBox != null
        ? this.props.viewBox
        : [0, 0, this.props.subject.width, this.props.subject.height]
    const { scale } = this.state // @getScale()

    // marks = @getCurrentMarks()
    let { marks } = this.state
    if (this.state.uncommittedMark != null) {
      marks = marks.concat(this.state.uncommittedMark)
    }

    const { transcribableMarks, otherMarks } = this.separateTranscribableMarks(
      marks
    )

    const actionButton = this.state.loading ? (
      <NextButton
        onClick={this.nextSubject}
        disabled={true}
        label="Loading..."
      />
    ) : (
      <NextButton onClick={this.nextSubject} label="Next Page" />
    )

    if (this.state.loading) {
      markingSurfaceContent = <LoadingIndicator />
    } else {
      markingSurfaceContent = (
        <svg
          className="subject-viewer-svg"
          viewBox={viewBox}
          data-tool={
            this.props.selectedDrawingTool != null
              ? this.props.selectedDrawingTool.type
              : undefined
          }
        >
          <rect
            ref="sizeRect"
            width={this.props.subject.width}
            height={this.props.subject.height}
          />
          <MouseHandler
            onStart={this.handleInitStart}
            onDrag={this.handleInitDrag}
            onEnd={this.handleInitRelease}
            inst="marking surface"
          >
            <SVGImage
              src={this.props.subject.location.standard}
              width={this.props.subject.width}
              height={this.props.subject.height}
            />
          </MouseHandler>
          {(() => {
            // HIGHLIGHT SUBJECT FOR TRANSCRIPTION
            // TODO: Make sure x, y, w, h are scaled properly
            if (['transcribe', 'verify'].includes(this.props.workflow.name)) {
              const { toolName } = this.props.subject.region

              const mark = this.props.subject.region

              if (mark.x != null && mark.y != null) {
                const ToolComponent = markingTools[toolName]
                const isPriorMark = true
                return (
                  <g>
                    {this.highlightMark(mark, toolName)}
                    <ToolComponent
                      key={this.props.subject.id}
                      xBound={this.props.subject.width}
                      yBound={this.props.subject.height}
                      mark={mark}
                      xScale={scale.horizontal}
                      yScale={scale.vertical}
                      disabled={isPriorMark}
                      selected={mark === this.state.selectedMark}
                      getEventOffset={this.getEventOffset}
                      ref={this.refs.sizeRect}
                      onSelect={this.selectMark.bind(
                        this,
                        this.props.subject,
                        mark
                      )}
                    />
                  </g>
                )
              }
            }
          })()}
          {this.renderMarks(otherMarks)}
          {this.renderMarks(transcribableMarks)}
        </svg>
      )
    }

    //  Render any tools passed directly in in same parent div so that we can efficiently position them with respect to marks"

    return (
      <div className={`subject-viewer${this.props.active ? ' active' : ''}`}>
        <div className="subject-container">
          <div className="marking-surface">
            {markingSurfaceContent}
            {this.props.children != null
              ? React.cloneElement(this.props.children, {
                loading: this.state.loading, // pass loading state to current transcribe tool
                scale
              })
              : undefined // pass scale down to children (for transcribe tools)
            }
          </div>
        </div>
      </div>
    )
  }
})

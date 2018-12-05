/*
 * decaffeinate suggestions:
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import PropTypes from 'prop-types'
import Draggable from '../../../../lib/draggable.jsx'
import DragHandle from './drag-handle.jsx'
import DeleteButton from '../../../buttons/delete-mark.jsx'
import MarkButtonMixin from '../../../../lib/mark-button-mixin.jsx'
import MarkLabel from '../mark-label.jsx'

const MINIMUM_SIZE = 30
const DELETE_BUTTON_DISTANCE_X = 16
const DELETE_BUTTON_DISTANCE_X_MARKED = 20
const DELETE_BUTTON_DISTANCE_Y = 0

let instances = []

@MarkButtonMixin
export default class RectangleTool extends React.Component {
  static propTypes = {
    // key:  PropTypes.number.isRequired
    mark: PropTypes.object.isRequired
  }

  static initCoords = null;

  static defaultValues({ x, y }) {
    return {
      x,
      y,
      width: 0,
      height: 0
    }
  }

  static initStart({ x, y }) {
    this.initCoords = { x, y }
    // hide when just created, to prevent it "flickering" into view
    // if it is directly destroyed afterwards
    return { x, y, hide: true, new: true }
  }

  static initMove(cursor, mark) {
    let height, width, x, y
    if (cursor.x > this.initCoords.x) {
      width = cursor.x - mark.x;
      ({ x } = mark)
    } else {
      width = this.initCoords.x - cursor.x;
      ({ x } = cursor)
    }

    if (cursor.y > this.initCoords.y) {
      height = cursor.y - mark.y;
      ({ y } = mark)
    } else {
      height = this.initCoords.y - cursor.y;
      ({ y } = cursor)
    }

    for (let item of instances) {
      if (item.props.mark === mark) {
        setTimeout(() => {
          item.updatePointsHash()
        })
      }
    }
    return { x, y, width, height, hide: false, new: false }
  }

  static initValid(mark) {
    return mark.width > MINIMUM_SIZE && mark.height > MINIMUM_SIZE
  }

  // This callback is called on mouseup to override mark properties (e.g. if too small)
  static initRelease(mark) {
    if (mark.new && mark.width < MINIMUM_SIZE && mark.height < MINIMUM_SIZE) {
      // Too small! Very probably an accidental release
      return
    }
    mark.width = Math.max(mark.width, MINIMUM_SIZE)
    mark.height = Math.max(mark.height, MINIMUM_SIZE)
  }

  constructor(props) {
    super(props)
    const { mark } = this.props
    if (mark.status == null) {
      mark.status = 'mark'
    }

    // set up the state in order to calculate the polyline as rectangle
    const x1 = mark.x
    const x2 = x1 + mark.width
    const y1 = mark.y
    const y2 = y1 + mark.height

    this.state = {
      pointsHash: this.createRectangleObjects(x1, x2, y1, y2),
      mark,
      buttonDisabled: false,
      lockTool: false
    }
  }

  componentWillMount() {
    instances.push(this)
  }

  componentWillUnmount() {
    instances = instances.filter(item => item !== this)
  }

  componentWillReceiveProps(newProps) {
    this.updatePointsHash(newProps)
  }

  updatePointsHash(props = this.props) {
    const x1 = props.mark.x
    const x2 = x1 + props.mark.width
    const y1 = props.mark.y
    const y2 = y1 + props.mark.height

    this.setState({
      pointsHash: this.createRectangleObjects(x1, x2, y1, y2)
    })
  }

  createRectangleObjects(x1, x2, y1, y2) {
    let HX, HY, LX, LY
    if (x1 < x2) {
      LX = x1
      HX = x2
    } else {
      LX = x2
      HX = x1
    }

    if (y1 < y2) {
      LY = y1
      HY = y2
    } else {
      LY = y2
      HY = y1
    }

    // PB: L and H seem to denote Low and High values of x & y, so:
    // LL: upper left
    // HL: upper right
    // HH: lower right
    // LH: lower left
    return {
      handleLLDrag: [LX, LY],
      handleHLDrag: [HX, LY],
      handleHHDrag: [HX, HY],
      handleLHDrag: [LX, HY]
    }
  }

  handleMainDrag(e, d) {
    if (this.state.locked) {
      return
    }
    if (this.props.disabled) {
      return
    }
    this.props.mark.x += d.x / this.props.xScale
    this.props.mark.y += d.y / this.props.yScale
    this.assertBounds()
    this.props.onChange(e)
    this.updatePointsHash()
  }

  dragFilter(key) {
    if (key === 'handleLLDrag') {
      return this.handleLLDrag
    }
    if (key === 'handleLHDrag') {
      return this.handleLHDrag
    }
    if (key === 'handleHLDrag') {
      return this.handleHLDrag
    }
    if (key === 'handleHHDrag') {
      return this.handleHHDrag
    }
  }

  handleLLDrag(e, d) {
    this.props.mark.x += d.x / this.props.xScale
    this.props.mark.width -= d.x / this.props.xScale
    this.props.mark.y += d.y / this.props.yScale
    this.props.mark.height -= d.y / this.props.yScale
    this.props.onChange(e)
    this.updatePointsHash()
  }

  handleLHDrag(e, d) {
    this.props.mark.x += d.x / this.props.xScale
    this.props.mark.width -= d.x / this.props.xScale
    this.props.mark.height += d.y / this.props.yScale
    this.props.onChange(e)
    this.updatePointsHash()
  }

  handleHLDrag(e, d) {
    this.props.mark.width += d.x / this.props.xScale
    this.props.mark.y += d.y / this.props.yScale
    this.props.mark.height -= d.y / this.props.yScale
    this.props.onChange(e)
    this.updatePointsHash()
  }

  handleHHDrag(e, d) {
    this.props.mark.width += d.x / this.props.xScale
    this.props.mark.height += d.y / this.props.yScale
    this.props.onChange(e)
    this.updatePointsHash()
  }

  assertBounds() {
    this.props.mark.x = Math.min(
      this.props.sizeRect.attributes.width.value - this.props.mark.width,
      this.props.mark.x
    )
    this.props.mark.y = Math.min(
      this.props.sizeRect.attributes.height.value - this.props.mark.height,
      this.props.mark.y
    )

    this.props.mark.x = Math.max(0, this.props.mark.x)
    this.props.mark.y = Math.max(0, this.props.mark.y)

    this.props.mark.width = Math.max(this.props.mark.width, MINIMUM_SIZE)
    this.props.mark.height = Math.max(
      this.props.mark.height,
      MINIMUM_SIZE)
  }

  validVert(y, h) {
    return y >= 0 && y + h <= this.props.sizeRect.attributes.height.value
  }

  validHoriz(x, w) {
    return x >= 0 && x + w <= this.props.sizeRect.attributes.width.value
  }

  getDeleteButtonPosition(pointsHash) {
    const points = pointsHash['handleHLDrag']
    let x = points[0] +
      ((this.props.selected && !this.props.disabled)
        ? DELETE_BUTTON_DISTANCE_X_MARKED : DELETE_BUTTON_DISTANCE_X) /
      this.props.xScale
    let y = points[1] + DELETE_BUTTON_DISTANCE_Y / this.props.yScale
    x = Math.min(x, this.props.sizeRect.attributes.width.value - 15 / this.props.xScale)
    y = Math.max(y, 15 / this.props.yScale)
    return { x, y }
  }

  getMarkButtonPosition() {
    const points = this.state.pointsHash['handleHHDrag']
    return {
      x: Math.min(
        points[0],
        this.props.sizeRect.attributes.width.value - 40 / this.props.xScale
      ),
      y: Math.min(
        points[1] + 20 / this.props.yScale,
        this.props.sizeRect.attributes.height.value - 15 / this.props.yScale
      )
    }
  }

  handleMouseDown() {
    this.props.onSelect(this.props.mark)
  }

  normalizeMark() {
    if (this.props.mark.width < 0) {
      this.props.mark.x += this.props.mark.width
      this.props.mark.width *= -1
    }

    if (this.props.mark.height < 0) {
      this.props.mark.y += this.props.mark.height
      this.props.mark.height *= -1
    }

    this.props.onChange()
  }

  render() {
    const classes = []
    if (this.props.isTranscribable) {
      classes.push('transcribable')
    }
    if (this.props.interim) {
      classes.push('interim')
    }
    classes.push(this.props.disabled ? 'committed' : 'uncommitted')
    if (this.checkLocation()) {
      classes.push('transcribing')
    }

    let { width, height } = this.props.mark
    if (Math.abs(width) < MINIMUM_SIZE) {
      width = Math.sign(width) * MINIMUM_SIZE
    }
    if (Math.abs(height) < MINIMUM_SIZE) {
      height = Math.sign(height) * MINIMUM_SIZE
    }

    const x1 = this.props.mark.x
    const x2 = x1 + width
    const y1 = this.props.mark.y
    const y2 = y1 + height

    const scale = (this.props.xScale + this.props.yScale) / 2

    const points = [
      [x1, y1].join(','),
      [x2, y1].join(','),
      [x2, y2].join(','),
      [x1, y2].join(','),
      [x1, y1].join(',')
    ].join('\n')

    const pointsHash = this.state.pointsHash
    return (
      <g
        data-tool={this}
        onMouseDown={this.props.onSelect}
        title={this.props.mark.label}
      >
        <g className={`rectangle-tool${this.props.disabled ? ' locked' : ''}`}>
          <Draggable onDrag={this.handleMainDrag.bind(this)}>
            <g
              className={`tool-shape ${classes.join(' ')}`}
              key={points}
              dangerouslySetInnerHTML={{
                __html: `\
<filter id="dropShadow"> \
<feGaussianBlur in="SourceAlpha" stdDeviation="3" /> \
<feOffset dx="2" dy="4" /> \
<feMerge> \
<feMergeNode /> \
<feMergeNode in="SourceGraphic" /> \
</feMerge> \
</filter> \
\
<polyline \
${this.props.mark.color != null && `stroke="${this.props.mark.color}"` || ''} \
points="${points}" \
filter="${this.props.selected ? 'url(#dropShadow)' : 'none'}" \
/>\
`
              }}
            />
          </Draggable>
          <MarkLabel fill={this.props.mark.color} x={x1 + width / 2} y={y1 + height / 2} label={this.props.mark.label} />
          {this.props.selected ? <DeleteButton
            onClick={this.props.onDestroy}
            scale={scale}
            x={this.getDeleteButtonPosition(this.state.pointsHash).x}
            y={this.getDeleteButtonPosition(this.state.pointsHash).y}
          /> : undefined}
          {this.props.selected && !this.props.disabled ? <g>
            {(() => {
              const result = []

              for (let key in pointsHash) {
                const value = pointsHash[key]
                result.push(
                  <DragHandle
                    key={key}
                    tool={this}
                    x={value[0]}
                    y={value[1]}
                    onDrag={this.dragFilter(key).bind(this)}
                    onEnd={this.normalizeMark.bind(this)}
                  />
                )
              }

              return result
            })()}
          </g> : undefined}
          {(() => {
            // REQUIRES MARK-BUTTON-MIXIN
            if ((this.props.selected || this.state.markStatus === 'transcribe-enabled') &&
              this.props.isTranscribable) {
              return this.renderMarkButton()
            }
          })()}
        </g>
      </g>
    )
  }
}

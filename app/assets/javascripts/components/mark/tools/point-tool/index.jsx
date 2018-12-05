/*
 * decaffeinate suggestions:
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import Draggable from '../../../../lib/draggable.jsx'
import DeleteButton from '../../../buttons/delete-mark.jsx'
import MarkButtonMixin from '../../../../lib/mark-button-mixin.jsx'

// DEFAULT SETTINGS
const RADIUS = 10
const SELECTED_RADIUS = 20
const CROSSHAIR_SPACE = 0.2
const CROSSHAIR_WIDTH = 1
const DELETE_BUTTON_ANGLE = 45

@MarkButtonMixin
export default class PointTool extends React.Component {
  static defaultValues({ x, y }) {
    return { x, y }
  }

  static initMove({ x, y }) {
    return { x, y }
  }

  getDeleteButtonPosition() {
    const theta = DELETE_BUTTON_ANGLE * (Math.PI / 180)
    return {
      x: (SELECTED_RADIUS / this.props.xScale) * Math.cos(theta) + 20,
      y: -1 * (SELECTED_RADIUS / this.props.yScale) * Math.sin(theta) - 20
    }
  }

  getMarkButtonPosition() {
    return {
      x: SELECTED_RADIUS / this.props.xScale,
      y: SELECTED_RADIUS / this.props.yScale
    }
  }

  handleDrag(e, d) {
    if (this.state.locked) {
      return
    }
    if (this.props.disabled) {
      return
    }
    this.props.mark.x += d.x / this.props.xScale
    this.props.mark.y += d.y / this.props.yScale
    this.props.onChange(e)
  }

  handleMouseDown() {
    this.props.onSelect(this.props.mark)
  } // unless @props.disabled

  render() {
    const classes = []
    if (this.props.isTranscribable) {
      classes.push('transcribable')
    }
    classes.push(this.props.disabled ? 'committed' : 'uncommitted')

    if (this.state.markStatus === 'mark-committed') {
      this.props.disabled = true
    }

    const averageScale = (this.props.xScale + this.props.yScale) / 2

    const crosshairSpace = CROSSHAIR_SPACE / averageScale
    const crosshairWidth = CROSSHAIR_WIDTH / averageScale
    const selectedRadius = SELECTED_RADIUS / averageScale

    const radius =
      this.props.selected || this.props.disabled
        ? SELECTED_RADIUS / averageScale
        : RADIUS / averageScale

    const scale = (this.props.xScale + this.props.yScale) / 2

    return (
      <g
        tool={this}
        transform={`translate(${this.props.mark.x}, ${this.props.mark.y})`}
        onMouseDown={this.handleMouseDown.bind(this)}
        title={this.props.mark.label}
      >
        <g className="point-tool">
          <Draggable onDrag={this.handleDrag.bind(this)}>
            <g
              className={`tool-shape ${classes.join(' ')}`}
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
<g ${this.props.mark.color != null && `stroke="${this.props.mark.color}"` || ''} > \
<line x1="0" y1="${-1 *
                  crosshairSpace *
                  selectedRadius}" x2="0" y2="${-1 *
                  selectedRadius}" strokeWidth="${crosshairWidth}" /> \
<line x1="${-1 * crosshairSpace * selectedRadius}" y1="0" x2="${-1 *
                  selectedRadius}" y2="0" strokeWidth="${crosshairWidth}" /> \
<line x1="0" y1="${crosshairSpace *
                  selectedRadius}" x2="0" y2="${selectedRadius}" strokeWidth="${crosshairWidth}" /> \
<line x1="${crosshairSpace *
                  selectedRadius}" y1="0" x2="${selectedRadius}" y2="0" strokeWidth="${crosshairWidth}" /> \
</g> \
\
<circle \
${this.props.mark.color != null && `stroke="${this.props.mark.color}"` || ''} \
r="${radius}" \
filter="${this.props.selected ? 'url(#dropShadow)' : 'none'}" \
/>\
`
              }}
            />
          </Draggable>
          {this.props.selected ?
            <DeleteButton
              onClick={this.props.onDestroy}
              scale={scale}
              x={this.getDeleteButtonPosition().x}
              y={this.getDeleteButtonPosition().y}
            /> : undefined}
          {(() => {
            // REQUIRES MARK-BUTTON-MIXIN
            if (this.props.selected ||
              this.state.markStatus === 'transcribe-enabled'
            ) {
              if (this.props.isTranscribable) {
                return this.renderMarkButton()
              }
            }
          })()}
        </g>
      </g>
    )
  }
}

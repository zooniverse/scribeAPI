/*
 * decaffeinate suggestions:
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import Draggable from '../../../../lib/draggable.jsx'
import DeleteButton from './delete-button.jsx'
import DragHandle from './drag-handle.jsx'
import MarkButtonMixin from '../../../../lib/mark-button-mixin.jsx'

const DEFAULT_HEIGHT = 100

@MarkButtonMixin
export default class TextRowTool extends React.Component {
  static defaultValues({ x, y }) {
    return {
      x,
      y: y - DEFAULT_HEIGHT / 2, // x and y will be the initial click position (not super useful as of yet)
      yUpper: y - DEFAULT_HEIGHT / 2,
      yLower: y + DEFAULT_HEIGHT / 2
    }
  }

  static initMove({ x, y }) {
    return {
      x,
      y: y - DEFAULT_HEIGHT / 2,
      yUpper: y - DEFAULT_HEIGHT / 2, // not sure if these are needed
      yLower: y + DEFAULT_HEIGHT / 2
    }
  }

  getDeleteButtonPosition() {
    return {
      x: 100,
      y: (this.props.mark.yLower - this.props.mark.yUpper) / 2
    }
  }

  getUpperHandlePosition() {
    return {
      x:
        (this.props.sizeRect != null
          ? this.props.sizeRect.attributes.width.value
          : undefined) / 2,
      y: this.props.mark.yUpper - this.props.mark.y
    }
  }

  getLowerHandlePosition() {
    return {
      x:
        (this.props.sizeRect != null
          ? this.props.sizeRect.attributes.width.value
          : undefined) / 2,
      y: this.props.mark.yLower - this.props.mark.y
    }
  }

  getMarkButtonPosition() {
    // NOTE: this somehow doesn't receive props in the first couple renders and produces an error --STI
    return {
      x:
        (this.props.sizeRect != null
          ? this.props.sizeRect.attributes.width.value
          : undefined) - 100,
      y: (this.props.mark.yLower - this.props.mark.yUpper) / 2
    }
  }

  render() {
    let isPriorMark
    if (this.state.markStatus === 'mark-committed') {
      isPriorMark = true
      this.props.disabled = true
    }

    const classes = []
    if (this.props.isTranscribable) {
      classes.push('transcribable')
    }
    classes.push(this.props.disabled ? 'committed' : 'uncommitted')

    return (
      <g
        tool={this}
        transform={`translate(0, ${this.props.mark.y})`}
        onMouseDown={this.handleMouseDown.bind(this)}
        title={this.props.mark.label}
      >
        <g
          className="text-row-tool"
          onMouseDown={!this.props.disabled ? this.props.onSelect : undefined}
        >
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
                  <rect \
                    ${this.props.mark.color != null ? `stroke="${this.props.mark.color}"` : ''} \
                    x="0" \
                    y="0" \
                    width="100%" \
                    height="${this.props.mark.yLower - this.props.mark.yUpper}" \
                    className="${isPriorMark ? 'previous-mark' : undefined}" \
                    filter="${this.props.selected ? 'url(#dropShadow)' : 'none'}" \
                  />\
                `
              }}
            />
          </Draggable>
          {this.props.selected && !this.state.locked &&
            <g>
              <DragHandle tool={this} onDrag={this.handleUpperResize.bind(this)} position={this.getUpperHandlePosition()} />
              <DragHandle tool={this} onDrag={this.handleLowerResize.bind(this)} position={this.getLowerHandlePosition()} />
              <DeleteButton tool={this} position={this.getDeleteButtonPosition()} />
            </g> || undefined}
          {(() => {
            // REQUIRES MARK-BUTTON-MIXIN
            if (this.props.selected || this.state.markStatus === 'transcribe-enabled'
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

  handleDrag(e, d) {
    if (this.state.locked) {
      return
    }
    if (this.props.disabled) {
      return
    }
    this.props.mark.y += d.y / this.props.yScale
    this.props.mark.yUpper += d.y / this.props.yScale
    this.props.mark.yLower += d.y / this.props.yScale
    this.props.onChange(e)
  }

  handleUpperResize(e, d) {
    this.props.mark.yUpper += d.y / this.props.yScale
    this.props.mark.y += d.y / this.props.yScale // fix weird resizing problem
    this.props.onChange(e)
  }

  handleLowerResize(e, d) {
    this.props.mark.yLower += d.y / this.props.yScale
    this.props.onChange(e)
  }

  handleMouseDown() { }
}
// @props.onSelect @props.mark # unless @props.disabled

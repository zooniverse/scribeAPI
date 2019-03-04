import React from 'react'

export default function MarkDrawingMixin(ComponentToWrap) {
  return class Extended extends ComponentToWrap {
    highlightMark(mark, toolName) {
      switch (toolName) {
        case 'rectangleTool':
          return <g>
            <rect
              className="mark-rectangle top"
              x={0}
              y={0}
              width={this.props.subject.width}
              height={mark.y}
              fill="rgba(0,0,0,0.6)"
            />
            <rect
              className="mark-rectangle bottom"
              x={0}
              y={mark.y + mark.height}
              width={this.props.subject.width}
              height={this.props.subject.height - mark.y + mark.height}
              fill="rgba(0,0,0,0.6)"
            />
            <rect
              className="mark-rectangle left"
              x={0}
              y={mark.y}
              width={mark.x}
              height={mark.height}
              fill="rgba(0,0,0,0.6)"
            />
            <rect
              className="mark-rectangle right"
              x={mark.x + mark.width}
              y={mark.y}
              width={this.props.subject.width - mark.width - mark.x}
              height={mark.height}
              fill="rgba(0,0,0,0.6)"
            />
          </g>
        case 'textRowTool':
          return <g>
            <rect
              className="mark-rectangle"
              x={0}
              y={0}
              width={this.props.subject.width}
              height={mark.yUpper}
              fill="rgba(0,0,0,0.6)"
            />
            <rect
              className="mark-rectangle"
              x={0}
              y={mark.yLower}
              width={this.props.subject.width}
              height={this.props.subject.height - mark.yLower}
              fill="rgba(0,0,0,0.6)"
            />
          </g>
      }
    }
  }
}

import React from 'react'
import PropTypes from 'prop-types'

let counter = 0

/**
 * Shows a label within a marking box, if show_labels is set to true in
 * the project.json.
 */
export default class MarkLabel extends React.Component {
  static propTypes = {
    x: PropTypes.number,
    y: PropTypes.number,
    label: PropTypes.string,
    fill: PropTypes.string
  }

  constructor(props) {
    super(props)
    this.state = { counter }
    counter++
  }

  render() {
    const { project } = window
    if (project.show_labels) {
      const { x, y, label } = this.props

      return <g>
        <defs>
          <filter x="0" y="0" width="1" height="1" id={`solid${this.state.counter}`}
            dangerouslySetInnerHTML={{
              __html: `<feFlood flood-color="${this.props.fill || 'black'}" /><feComposite in="SourceGraphic" />`
            }}>
          </filter>
        </defs>
        <text filter={`url(#solid${this.state.counter})`} x={x} y={y} fontSize="30" fill="#000" stroke="none" className="mark-label">{label}</text>
      </g>
    } else {
      return null
    }
  }
}

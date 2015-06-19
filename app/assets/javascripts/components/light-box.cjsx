React               = require 'react'
SVGImage            = require './svg-image'


module.exports = React.createClass
  displayName: 'LightBox'

  propTypes:
    subject_set: React.PropTypes.object.isRequired
    subject_index: React.PropTypes.number.isRequired


  getInitialState: ->
    subjects: @props.subject_set.subjects

  render: ->
    console.log "lB props", @props
    console.log "lB state", @state

    viewBox = [0, 0, 100, 100]
    <div className="carousel">
      <ul>
          {for subject, index in @state.subjects
            <li key={index} visibility = {@visibleProperty(index)}> 
              <svg className="light-box-subject" width={300} height={300} viewBox={viewBox} >
                  <SVGImage
                    src = {subject.location.standard}
                    width = {100}
                    height = {100} 
                  />
              </svg>
            </li>
          }
      </ul>
    </div>

  visibleProperty: (index) ->
    if index == @props.subject_index
      "visible"
    else
      "hidden"
  seeNextSubject: ->





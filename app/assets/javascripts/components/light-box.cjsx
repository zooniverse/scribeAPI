React               = require 'react'
SVGImage            = require './svg-image'


module.exports = React.createClass
  displayName: 'LightBox'

  propTypes:
    subject_set: React.PropTypes.object.isRequired

  getInitialState: ->
    subjects: @props.subject_set.subjects
    currentSubjectIndex: 0 

  render: ->
    console.log "IS THE LIGHT BOX EXISTSINT"
    console.log "lB props", @props
    console.log "lB state", @state

    viewBox = [0, 0, 100, 100]
    <div className="carousel">
      <ul>
        {
          for subject, i in @state.subjects
            <li key={i}> 
              <svg className="light-box-subject" width={300} height={300} viewBox={viewBox} >
                  <SVGImage
                    src = {subject.location.standard}
                    width = {100}
                    height = {100} />
              </svg>
            </li>
        }
      </ul>
    </div>

  seeNextSubject: ->





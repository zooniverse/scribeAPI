React               = require 'react'
SVGImage            = require './svg-image'
ActionButton                  = require './action-button'



module.exports = React.createClass
  displayName: 'LightBox'

  propTypes:
    subject_set: React.PropTypes.object.isRequired
    subject_index: React.PropTypes.number.isRequired
    # onSubject: React.PropTypes.func.isRequired

  shineSelected: (index)->
    console.log "Shine index", index
    @props.onSubject(index)

  render: ->
    console.log "lB props", @props
    console.log "lB state", @state

    viewBox = [0, 0, 100, 100]
    <div className="carousel">

      <ActionButton text="UP" onClick={console.log "move up"} classes={if @props.subject_index == 0 then 'disabled' else ''}/>

      <ul>
          {for subject, index in @props.subject_set.subjects
            <li key={index} visibility = {@visibleProperty(index)} onClick={@shineSelected.bind(this, index)}> 
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

      <ActionButton text="DOWN" onClick={console.log "move down"} classes={if @props.subject_index == @props.subject_set.subjects.length-1 then 'disabled' else ''} />

    </div>

  visibleProperty: (index) ->
    if index == @props.subject_index
      "visible"
    else
      "hidden"
  
  seeNextSubject: ->





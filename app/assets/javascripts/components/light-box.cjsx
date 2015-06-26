React               = require 'react'
SVGImage            = require './svg-image'
ActionButton                  = require './action-button'



module.exports = React.createClass
  displayName: 'LightBox'

  propTypes:
    subject_set: React.PropTypes.object.isRequired
    subject_index: React.PropTypes.number.isRequired
    onSubject: React.PropTypes.func.isRequired

  getInitialState:->
    first: @props.subject_set.subjects[@props.subject_index]


  shineSelected: (index)->
    @props.onSubject(index)

  render: ->
    return null if @props.subject_set.subjects.length <= 1
    indexOfFirst = @findSubjectIndex(@state.first)

    second = @props.subject_set.subjects[indexOfFirst+1] 
    third = @props.subject_set.subjects[indexOfFirst+2]


    viewBox = [0, 0, 100, 100]
    <div className="carousel">

      <ActionButton id="backward" text="BACK" onClick={@moveBack.bind(this, indexOfFirst)} classes={@backButtonDisable()} />

      <ul>
        <li onClick={@shineSelected.bind(this, @findSubjectIndex(@state.first))} className={"active" if @props.subject_index == @findSubjectIndex(@state.first)}> 
          <svg className="light-box-subject" width={200} height={200} viewBox={viewBox} >
              <SVGImage
                src = {@state.first.location.standard}
                width = {100}
                height = {100} 
              />
          </svg>
        </li>
        {if second
          <li onClick={@shineSelected.bind(this, @findSubjectIndex(second))} className={"active" if @props.subject_index == @findSubjectIndex(second)} > 
            <svg className="light-box-subject" width={200} height={200} viewBox={viewBox} >
                <SVGImage
                  src = {second.location.standard}
                  width = {100}
                  height = {100} 
                />
            </svg>
          </li>
        }

        {if third
          <li onClick={@shineSelected.bind(this, @findSubjectIndex(third))} className={"active" if @props.subject_index == @findSubjectIndex(third)} > 
            <svg className="light-box-subject" width={200} height={200} viewBox={viewBox} >
                <SVGImage
                  src = {third.location.standard}
                  width = {100}
                  height = {100} 
                />
            </svg>
          </li>
        }
      </ul>
      <ActionButton id="forward" text="FORWARD" onClick={@moveForward.bind(this, indexOfFirst)} classes={@forwardButtonDisable(third if third?)} />

    </div>

  backButtonDisable: ->
    # 1) if the subject sets list is less than two
    if @state.first == @props.subject_set.subjects[0] || @props.subject_set.subjects.length <= 3
      return "disabled"
    else
      return ""

  forwardButtonDisable: (third) ->
    console.log "T?F third == @props.subject_set.subjects[@props.subject_set.subjects.length-1]", third == @props.subject_set.subjects[@props.subject_set.subjects.length-1]
    console.log "T?F @props.subject_set.subjects.length <= 3", @props.subject_set.subjects.length <= 3
    if @props.subject_set.subjects.length <= 3 || third == @props.subject_set.subjects[@props.subject_set.subjects.length-1] 
      return "disabled" 
    else 
      return ""
  
  findSubjectIndex: (subject_arg)->
    for subject, index in @props.subject_set.subjects
      if subject.id == subject_arg.id
        return index
      else
        console.log "WARN: unable to run LightBox#findSubjectIndex"

  moveBack: (indexOfFirst)->
    return null if @props.subject_set.subjects.length <= 3 || @props.subject_set.subjects[indexOfFirst] == @props.subject_set.subjects[0]
    @setState
      first: @props.subject_set.subjects[indexOfFirst-1]

  moveForward: (indexOfFirst)->
    console.log "T?F @props.subject_set.subjects.length <= 3", @props.subject_set.subjects.length <= 3
    console.log "T?F @props.subject_set.subjects[indexOfFirst+2] == @props.subject_set.subjects[@props.subject_set.subjects.length-1]", @props.subject_set.subjects[indexOfFirst+2] == @props.subject_set.subjects[@props.subject_set.subjects.length-1] 
    return null if @props.subject_set.subjects.length <= 3 || @props.subject_set.subjects[indexOfFirst+2] == @props.subject_set.subjects[@props.subject_set.subjects.length-1] 
    @setState
      first: @props.subject_set.subjects[indexOfFirst+1]
    








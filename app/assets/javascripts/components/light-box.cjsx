React               = require 'react'
SVGImage            = require './svg-image'
ActionButton        = require './action-button'

module.exports = React.createClass
  displayName: 'LightBox'

  propTypes:
    subject_set: React.PropTypes.object.isRequired
    subject_index: React.PropTypes.number.isRequired
    onSubject: React.PropTypes.func.isRequired
    nextPage: React.PropTypes.func.isRequired
    prevPage: React.PropTypes.func.isRequired
    totalSubjectPages: React.PropTypes.number.isRequired
    subjectCurrentPage: React.PropTypes.number.isRequired


  getInitialState:->
    first: @props.subject_set.subjects[0]
    folded: false

  handleFoldClick: (e)->

    @setState folded: !@state.folded

  lightBoxMessage:=>
    if @state.folded
      text = "Show Lightbox"
    else
      text = "Hide Lightbox"

  render: ->
    window.subjects = @props.subject_set.subjects
    return null if @props.subject_set.subjects.length <= 1
    indexOfFirst = @findSubjectIndex(@state.first)
    second = @props.subject_set.subjects[indexOfFirst+1]
    third = @props.subject_set.subjects[indexOfFirst+2]

    viewBox = [0, 0, 100, 100]


    if @state.folded
      carouselStyle ={
        display: "none"
      }
    if @state.folded
      text = "Show Lightbox"
    else
      text = "Hide Lightbox"

    classes = []
    if @props.isDisabled
      classes.push 'disabled'
    else
    <div className="carousel" >
      <div id="visibility-button" onClick={@handleFoldClick}>{text}</div>

      <div id="image-list" className={classes} style={carouselStyle} >
        <ul>
          <li onClick={@shineSelected.bind(this, @findSubjectIndex(@state.first))} className={"active" if @props.subject_index == @findSubjectIndex(@state.first) }>
            <span class="page-number">{@state.first.order}</span>

            <svg className="light-box-subject" width={125} height={125} viewBox={viewBox} >
                <SVGImage
                  src = {@state.first.location.standard}
                  width = {100}
                  height = {100}
                />
            </svg>
          </li>
          {if second
            <li onClick={@shineSelected.bind(this, @findSubjectIndex(second))} className={"active" if @props.subject_index == @findSubjectIndex(second)} >
              <span class="page-number">{second.order}</span>
              <svg className="light-box-subject" width={125} height={125} viewBox={viewBox} >
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
              <span class="page-number">{third.order}</span>
              <svg className="light-box-subject" width={125} height={125} viewBox={viewBox} >
                  <SVGImage
                    src = {third.location.standard}
                    width = {100}
                    height = {100}
                  />
              </svg>
            </li>
          }
        </ul>
      </div>

      <ActionButton type={"back"} text="BACK" onClick={@moveBack.bind(this, indexOfFirst)} classes={@backButtonDisable(indexOfFirst)} />
      <ActionButton type={"next"} text="NEXT" onClick={@moveForward.bind(this, indexOfFirst, third, second)} classes={@forwardButtonDisable(third if third?)} />

    </div>

  # allows user to click on a subject in the lightbox to load that subject into the subject-viewer.
  # This method ultimately sets the state.subject_index in mark/index. See subject-set-viewer#specificSelection() and mark/index#handleViewSubject().
  shineSelected: (index)->
    @props.onSubject(index)

  # determines the back button css
  backButtonDisable:(indexOfFirst) ->
    if @props.subjectCurrentPage == 1 && @props.subject_set.subjects[indexOfFirst] == @props.subject_set.subjects[0]
      return "disabled"
    else
      return ""

  # determines the forward button css
  forwardButtonDisable: (third) ->
    if @props.subjectCurrentPage == @props.totalSubjectPages && (@props.subject_set.subjects.length <= 3 || third == @props.subject_set.subjects[@props.subject_set.subjects.length-1])
      return "disabled"
    else
      return ""

  # finds the index of a given subject within the current page of the subject_set
  findSubjectIndex: (subject_arg)->
    return @props.subject_set.subjects.indexOf subject_arg

  # allows user to naviagate back though a subject_set
  # # controlls navigation of current page of subjects as well as the method that pull a new page of subjects
  moveBack: (indexOfFirst)->
    # if the current page of subjects is the first page of subjects, and the first <li> is the first subject in the page of subjects.
    return if @props.subjectCurrentPage == 1 && @props.subject_set.subjects[indexOfFirst] == @props.subject_set.subjects[0]
    else if @props.subjectCurrentPage > 1 && @props.subject_set.subjects[indexOfFirst] == @props.subject_set.subjects[0]
      @props.prevPage( => @setState first: @props.subject_set.subjects[0] )
    else
      @setState first: @props.subject_set.subjects[indexOfFirst-3]

  moveForward: (indexOfFirst, third, second)->
    # if the current page of subjects is the last page of the subject_set and the 2nd or 3rd <li> is the last <li> contain the last subjects in the subject_set
    return if @props.subjectCurrentPage == @props.totalSubjectPages && (third == @props.subject_set.subjects[@props.subject_set.subjects.length-1] || second == @props.subject_set.subjects[@props.subject_set.subjects.length-1])
    # # if the current page of subjects is NOT the last page of the subject_set and the 2nd or 3rd <li> is the last <li> contain the last subjects in the subject_set
    if @props.subjectCurrentPage < @props.totalSubjectPages && (third == @props.subject_set.subjects[@props.subject_set.subjects.length-1] || second == @props.subject_set.subjects[@props.subject_set.subjects.length-1])
      @props.nextPage( => @setState first: @props.subject_set.subjects[0] )
      # NOTE: for some reason, LightBox does not receive correct value for @props.subject_index, which has led to this awkard callback function above --STI
      # @setState first: @props.subject_set.subjects[0], => @forceUpdate()

    # there are further subjects to see in the currently loaded page
    else
      @setState first: @props.subject_set.subjects[indexOfFirst+3]

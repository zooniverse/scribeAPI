React               = require 'react'
SVGImage            = require './svg-image'
ActionButton        = require './action-button'
HelpModal           = require './help-modal'

module.exports = React.createClass
  displayName: 'LightBox'

  propTypes:
    subject_set: React.PropTypes.object.isRequired
    subject_index: React.PropTypes.number.isRequired
    onSubject: React.PropTypes.func.isRequired
    nextPage: React.PropTypes.func.isRequired
    prevPage: React.PropTypes.func.isRequired
    totalSubjectPages: React.PropTypes.number
    subjectCurrentPage: React.PropTypes.number

  getInitialState:->
    first: @props.subject_set.subjects[0]
    folded: false

  componentWillReceiveProps: ->
    console.log 'SUBJECT INDEX = ', @props.subject_index
    page = Math.floor( @props.subject_index/3 )
    # console.log 'PAGE = ', page
    @setState first: @props.subject_set.subjects[ 3 * page ]

  handleFoldClick: (e)->
    @setState folded: !@state.folded

  lightBoxMessage:=>
    if @state.folded
      text = "Show Lightbox"
    else
      text = "Hide Lightbox"

  render: ->
    # console.log 'LIGHT-BOX::render(), @state.first = ', @state.first
    # window.subjects = @props.subject_set.subjects # pb ?
    return null if @props.subject_set.subjects.length <= 1
    indexOfFirst = @findSubjectIndex(@state.first)
    first = @props.subject_set.subjects[indexOfFirst]
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

    containerClasses = []
    containerClasses.push "light-box-area"
    if @state.folded then containerClasses.push "folded"

    <div className={containerClasses.join ' '}>
      <div className="carousel" >
        <div id="visibility-button" >

          <svg onClick={@props.toggleLightboxHelp} id="questions-tip" width="14px" height="14px" viewBox="0 0 14 14">
            <path fillRule="evenodd" d="M 7 0C 3.13 0-0 3.13-0 7-0 10.87 3.13 14 7 14 10.87 14 14 10.87 14 7 14 3.13 10.87 0 7 0ZM 7.04 11.13C 6.51 11.13 6.07 10.68 6.07 10.15 6.07 9.63 6.51 9.18 7.04 9.18 7.57 9.18 8.01 9.63 8.01 10.15 8.01 10.68 7.57 11.13 7.04 11.13ZM 7.56 7.66C 7.56 7.85 7.65 8.06 7.77 8.16 7.77 8.16 6.47 8.55 6.47 8.55 6.21 8.27 6.07 7.91 6.07 7.49 6.07 6.06 7.82 5.9 7.82 5.07 7.82 4.7 7.54 4.39 6.89 4.39 6.29 4.39 5.78 4.69 5.41 5.13 5.41 5.13 4.44 4.04 4.44 4.04 5.07 3.29 6.03 2.87 7.07 2.87 8.61 2.87 9.56 3.65 9.56 4.77 9.56 6.52 7.56 6.65 7.56 7.66Z" fill="rgb(187,191,195)"/>
          </svg>

        </div>

        <div id="image-list" className={classes} style={carouselStyle} >
          <ul>
            <li onClick={@shineSelected.bind(this, @findSubjectIndex(@state.first))} className={"active" if @props.subject_index == @findSubjectIndex(@state.first) }>
              <span className="page-number">{@state.first.order}</span>

              <svg className="light-box-subject" width={125} height={125} viewBox={viewBox} >
                  <SVGImage
                    src = {if @state.first.location.thumbnail? then @state.first.location.thumbnail else @state.first.location.standard}
                    width = {100}
                    height = {100}
                  />
              </svg>
            </li>
            {if second
              <li onClick={@shineSelected.bind(this, @findSubjectIndex(second))} className={"active" if @props.subject_index == @findSubjectIndex(second)} >
                <span className="page-number">{second.order}</span>
                <svg className="light-box-subject" width={125} height={125} viewBox={viewBox} >
                    <SVGImage
                      src = {if second.location.thumbnail? then second.location.thumbnail else second.location.standard}
                      width = {100}
                      height = {100}
                    />
                </svg>
              </li>
            }

            {if third
              <li onClick={@shineSelected.bind(this, @findSubjectIndex(third))} className={"active" if @props.subject_index == @findSubjectIndex(third)} >
                <span className="page-number">{third.order}</span>
                <svg className="light-box-subject" width={125} height={125} viewBox={viewBox} >
                    <SVGImage
                      src = {if third.location.thumbnail? then third.location.thumbnail else third.location.standard}
                      width = {100}
                      height = {100}
                    />
                </svg>
              </li>
            }
          </ul>

          <ActionButton type={"back"} text="BACK" onClick={@moveBack.bind(this, indexOfFirst)} classes={@backButtonDisable(indexOfFirst)} />
          <ActionButton type={"next"} text="NEXT" onClick={@moveForward.bind(this, indexOfFirst, third, second, first)} classes={@forwardButtonDisable(third if third?)} />

        </div>

      </div>
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
    # PB sometimes equality is failing on subjects, so let's try just matching id
    # return @props.subject_set.subjects.indexOf subject_arg
    return (s.id for s in @props.subject_set.subjects).indexOf subject_arg.id

  # allows user to naviagate back though a subject_set
  # # controlls navigation of current page of subjects as well as the method that pull a new page of subjects
  moveBack: (indexOfFirst)->
    # if the current page of subjects is the first page of subjects, and the first <li> is the first subject in the page of subjects.
    if @props.subjectCurrentPage == 1 && @props.subject_set.subjects[indexOfFirst] == @props.subject_set.subjects[0]
      console.log 'moveBackward: A'
      return
    else if @props.subjectCurrentPage > 1 && @props.subject_set.subjects[indexOfFirst] == @props.subject_set.subjects[0]
      console.log 'moveBackward: A'
      @props.prevPage( => @setState first: @props.subject_set.subjects[0] )
    else
      console.log 'moveBackward: A'
      @setState first: @props.subject_set.subjects[indexOfFirst-3]

  moveForward: (indexOfFirst, third, second, first)->
    console.log 'TOTAL SUBJECT PAGES = ', @props.totalSubjectPages
    console.log 'CURRENT SUBJECT PAGE = ', @props.subjectCurrentPage



    # if the current page of subjects is the last page of the subject_set and the 2nd or 3rd <li> is the last <li> contain the last subjects in the subject_set
    if @props.subjectCurrentPage == @props.totalSubjectPages && (third == @props.subject_set.subjects[@props.subject_set.subjects.length-1] || second == @props.subject_set.subjects[@props.subject_set.subjects.length-1] || first == @props.subject_set.subjects[@props.subject_set.subjects.length-1])
      console.log 'TOTAL SUBJECT PAGES = ', @props.totalSubjectPages
      console.log 'moveForward: A'
      console.log 'THAT WAS THE LAST PAGE IN THE LOGBOOK!'
      return

    # FETCH SUBJECTS FROM NEXT PAGINATION
    # if the current page of subjects is NOT the last page of the subject_set and the 2nd or 3rd <li> is the last <li> contain the last subjects in the subject_set
    else if @props.subjectCurrentPage < @props.totalSubjectPages && (third == @props.subject_set.subjects[@props.subject_set.subjects.length-1] || second == @props.subject_set.subjects[@props.subject_set.subjects.length-1])
      console.log 'moveForward: B'
      @props.nextPage( => @setState first: @props.subject_set.subjects[0])
      # NOTE: for some reason, LightBox does not receive correct value for @props.subject_index, which has led to this awkard callback function above --STI
      # @setState first: @props.subject_set.subjects[0], => @forceUpdate()

    # LOAD NEXT 3 SUBJECTS INTO LIGHT BOX
    # there are further subjects to see in the currently loaded page
    else
      console.log 'moveForward: C'
      @setState first: @props.subject_set.subjects[indexOfFirst+3]

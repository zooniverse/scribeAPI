React                         = require 'react'
LightBox                      = require './light-box'
SubjectZoomPan                = require 'components/subject-zoom-pan'
ForumSubjectWidget            = require './forum-subject-widget'
{Link}                        = require 'react-router'


module.exports = React.createClass
  displayName: "SubjectSetToolbar"

  propTypes: 
    hideOtherMarks: React.PropTypes.bool.isRequired
    project: React.PropTypes.object.isRequired
    toggleTutorial: React.PropTypes.func.isRequired
    completeTutorial: React.PropTypes.bool.isRequired


  getInitialState: ->
    subject_set: @props.subject_set
    zoomPanViewBox: @props.viewBox
    active_pane: ''
    hideMarks: true

  componentDidMount: ->
    window.addEventListener "keydown", (e) => @_handleZoomKeys(e)

  togglePane: (name) ->
    if @state.active_pane == name
      @setState active_pane: ''
      @props.onHide()
    else
      @setState active_pane: name
      @props.onExpand()

  render: ->
    # disable LightBox if work has begun
    disableLightBox = if @props.task.key isnt @props.workflow.first_task then true else false
    <div className="subject-set-toolbar">
      <div className="subject-set-toolbar-panes">
        <div className={"light-box-area multi-page pane" + if @state.active_pane == 'multi-page' then ' active' else '' }>
          <LightBox
            subject_set={@props.subject_set}
            subject_index={@props.subject_index}
            key={@props.subject_set.subjects[0].id}
            isDisabled={disableLightBox}
            toggleLightboxHelp={@props.lightboxHelp}
            onSubject={@props.onSubject}
            subjectCurrentPage={@props.subjectCurrentPage}
            nextPage={@props.nextPage}
            prevPage={@props.prevPage}
            totalSubjectPages={@props.totalSubjectPages}
            />
        </div>
        <div className={"pan-zoom-area pan-zoom pane" + if @state.active_pane == 'pan-zoom' then ' active' else '' }>
          <SubjectZoomPan subject={@props.subject} onChange={@props.onZoomChange} viewBox={@state.zoomPanViewBox}/>
        </div>
        <div className={"social-media-container pane" + if @state.active_pane == 'share' then ' active' else '' }>
          <a href="https://www.facebook.com/sharer.php?u=#{encodeURIComponent @props.pageURL}" target="_blank">
            <i className="fa fa-facebook-square fa-3x"/>
          </a>
          <a href="https://twitter.com/home?status=#{encodeURIComponent @props.pageURL}%0A" target="_blank">
            <i className="fa fa-twitter-square fa-3x"/>
          </a>
          <a href="https://plus.google.com/share?url=#{encodeURIComponent @props.pageURL}" target="_blank">
            <i className="fa fa-google-plus-square fa-3x"/>
          </a>
        </div>

        <div className={"forum-holder pane" + if @state.active_pane == 'discuss' then ' active' else '' } >
            <ForumSubjectWidget subject_set={@props.subject_set} project={@props.project} />
        </div>

         <div className={"explore pane" + if @state.active_pane == 'explore' then ' active' else ''} >
          <h2>Explore</h2>
          <p>
            <Link to="/groups/#{@props.subject_set.group_id}">About this {@props.project.term('group')}.</Link>
          </p>
        </div>

      </div>
      <div className="subject-set-toolbar-links">
        <a className={"toggle-pan-zoom" + if @state.active_pane == 'pan-zoom' then ' active' else '' } title="Toggle pan and zoom tool" onClick={() => @togglePane 'pan-zoom'}></a>
        <a className={"toggle-multi-page" + if @props.subject_set.subjects.length <= 1 then ' disabled' else '' + if @state.active_pane == 'multi-page' then ' active' else '' } title="Toggle multi-page navigation" onClick={() => @togglePane 'multi-page'}></a>
        <a className={if @props.hideOtherMarks == true then 'fa fa-toggle-on fa-2x' else 'fa fa-toggle-off fa-2x' } title="Hide Marks of Other People" onClick={@props.toggleHideOtherMarks}></a>
        <a className={"fa fa-comments-o" + if @state.active_pane == 'discuss' then ' active' else '' } title="Discuss this page" onClick={() => @togglePane 'discuss'}></a>
        <a className={"fa fa-share-alt" + if @state.active_pane == 'share' then ' active' else '' } title="Share this image" onClick={() => @togglePane 'share'}></a>
        <a className={"fa fa-info" + if @state.active_pane == 'explore' then ' active' else '' } title="More information on this subject" onClick={() => @togglePane 'explore'}></a>
        <a className={"fa fa-question" + if @props.completeTutorial != true then ' active' else ''} title="Tutorial" onClick={@props.toggleTutorial}></a>

      </div>
    </div>

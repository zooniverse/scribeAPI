React                         = require 'react'
LightBox                      = require './light-box'
SubjectZoomPan                = require 'components/subject-zoom-pan'
ForumSubjectWidget            = require './forum-subject-widget'
{Link}                        = require 'react-router'


module.exports = React.createClass
  displayName: "SubjectSetToolbar"

  propTypes:
    hideOtherMarks: React.PropTypes.bool.isRequired

  getInitialState: ->
    subject_set: @props.subject_set
    zoomPanViewBox: @props.viewBox
    active_pane: ''
    hideMarks: true

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
          { if @props.subject_set
              <LightBox
                subject_set={@props.subject_set}
                subject_index={@props.subject_index}
                key={@props.subject_set.subjects[0].id}
                isDisabled={disableLightBox}
                toggleLightboxHelp={@props.lightboxHelp}
                onSubject={@props.onSubject}
                currentSubjectPage={@props.currentSubjectPage}
                nextPage={@props.nextPage}
                prevPage={@props.prevPage}
                totalSubjectPages={@props.totalSubjectPages}
                />
          }
        </div>
        <div className={"pan-zoom-area pan-zoom pane" + if @state.active_pane == 'pan-zoom' then ' active' else '' }>
          <SubjectZoomPan subject={@props.subject} onChange={@props.onZoomChange} viewBox={@state.zoomPanViewBox}/>
        </div>


      </div>
      <div className="subject-set-toolbar-links">
        <a className={"toggle-pan-zoom" + if @state.active_pane == 'pan-zoom' then ' active' else '' } onClick={() => @togglePane 'pan-zoom'}><div className="helper">Toggle pan and zoom tool</div></a>
        <a className={"toggle-multi-page" + if @props.subject_set.subjects.length <= 1 then ' disabled' else '' + if @state.active_pane == 'multi-page' then ' active' else '' } onClick={() => @togglePane 'multi-page'}><div className="helper">Toggle multi-page navigation</div></a>
        <a className={if @props.hideOtherMarks == true then 'fa fa-toggle-on fa-2x' else 'fa fa-toggle-off fa-2x' } onClick={@props.toggleHideOtherMarks}><div className="helper">{if @props.hideOtherMarks == false then "Hide Marks of Other People" else "Showing Only Your Marks"}</div></a>
      </div>
    </div>

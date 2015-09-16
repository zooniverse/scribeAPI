React                         = require 'react'
LightBox                      = require './light-box'
SubjectZoomPan                = require 'components/subject-zoom-pan'

module.exports = React.createClass
  displayName: "SubjectSetToolbar"

  getInitialState: ->
    subject_set: @props.subject_set
    zoomPanViewBox: @props.viewBox
    active_pane: ''

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
      </div>
      <div className="subject-set-toolbar-links">
        <a className={"toggle-pan-zoom" + if @state.active_pane == 'pan-zoom' then ' active' else '' } onClick={() => @togglePane 'pan-zoom'}><div className="helper">Toggle pan and zoom tool</div></a>
        <a className={"toggle-multi-page" + if @props.subject_set.subjects.length <= 1 then ' disabled' else '' + if @state.active_pane == 'multi-page' then ' active' else '' } onClick={() => @togglePane 'multi-page'}><div className="helper">Toggle multi-page navigation</div></a>
      </div>
    </div>

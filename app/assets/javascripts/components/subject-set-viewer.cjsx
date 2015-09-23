 # @cjsx React.DOM
React                         = require 'react'
SubjectViewer                 = require './subject-viewer'
{Router, Routes, Route, Link} = require 'react-router'
SVGImage                      = require './svg-image'
Draggable                     = require '../lib/draggable'
LoadingIndicator              = require './loading-indicator'
SubjectMetadata               = require './subject-metadata'
ActionButton                  = require './action-button'
markingTools                  = require './mark/tools'
ZoomPanListenerMethods        = require 'lib/zoom-pan-listener-methods'
SubjectSetToolbar             = require './subject-set-toolbar'

module.exports = React.createClass
  displayName: 'SubjectSetViewer'
  resizing: false

  mixins: [ZoomPanListenerMethods]

  getInitialState: ->
    subject_set: @props.subject_set
    tool: @props.tool
    toolbar_expanded: false
    # subject_index: @props.subject_index ? 0pmark

  advancePrevious: ->
    @advance -1

  advanceNext: ->
    @advance 1

  advance: (count) ->
    new_index = @props.subject_index + count
    return if new_index < 0 || new_index >= @props.subject_set.subjects.length

    # Let's just deal in indexes rather than storing both objects and indexes in state, lest they drift out of sync
    # @setState subject_index: new_index, () =>
    @props.onViewSubject? new_index # @props.subject_index

  specificSelection: (blah, new_index) ->
    # this prevents navigating away from the subject during a workflow --AMS
    if @props.workflow.first_task == @props.task.key
      @props.onViewSubject? new_index
    else
      return null

  onToolbarExpand: ->
    @setState toolbar_expanded: true

  onToolbarHide: ->
    @setState toolbar_expanded: false

  render: ->
    # console.log 'SUBJECT-SET-VIEWER::render(), subject_index = ', @props.subject_index
    # NOTE: LightBox does not receive correct @props.subject_index. Why? --STI
    <div className={"subject-set-viewer" + if @state.toolbar_expanded then ' expand' else ''}>
      <SubjectSetToolbar
        workflow={@props.workflow}
        task={@props.task}
        subject={@props.subject_set.subjects[@props.subject_index]}
        subject_set={@props.subject_set}
        subject_index={@props.subject_index}
        subjectCurrentPage={@props.subjectCurrentPage}
        lightboxHelp={@props.lightboxHelp}
        onSubject={@specificSelection.bind this, @props.subject_index}
        nextPage={@props.nextPage}
        prevPage={@props.prevPage}
        totalSubjectPages={@props.totalSubjectPages}
        onZoomChange={@handleZoomPanViewBoxChange}
        viewBox={@state.zoomPanViewBox}
        onExpand={@onToolbarExpand}
        onHide={@onToolbarHide}
        hideOtherMarks={@props.hideOtherMarks}
        toggleHideOtherMarks={@props.toggleHideOtherMarks}
        pageURL={@props.pageURL}
        project={@props.project}
        toggleTutorial={@props.toggleTutorial}
        completeTutorial={@props.completeTutorial}
        showingTutorial={@props.showingTutorial}
      />

      { for subject, index in @props.subject_set.subjects
        <SubjectViewer
          key={index}
          subject={subject}
          workflow={@props.workflow}
          task={@props.task}
          subjectCurrentPage={@props.subjectCurrentPage}
          annotation={@props.annotation}
          active={index == @props.subject_index}
          onComplete={@props.onComplete}
          onChange={@props.onChange}
          onDestroy={@props.onDestroy}
          subToolIndex={@props.subToolIndex}
          destroyCurrentClassification={@props.destroyCurrentClassification}
          hideOtherMarks={@props.hideOtherMarks}
          currentSubtool={@props.currentSubtool}
          viewBox={@state.zoomPanViewBox}
        />
      }
    </div>

window.React = React

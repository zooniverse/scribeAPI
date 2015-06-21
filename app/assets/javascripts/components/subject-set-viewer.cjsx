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
LightBox                       = require './light-box'


module.exports = React.createClass
  displayName: 'SubjectSetViewer'
  resizing: false

  getInitialState: ->
    subject_set: @props.subject_set
    tool: @props.tool
    # subject_index: @props.subject_index ? 0

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

      # @props.onViewSubject? @props.subject_set.subjects[@state.subject_index]
  specificSelection: (new_index) ->
    @props.onViewSubject? new_index


  render: ->
    console.log " SSV Render @props", @props
    # console.log " SSV Render @state", @state
    console.log "...Current Classification: ", @props.annotation
    <div className="subject-set-viewer">
    <div className="light-box-area">
      {
        subject_index = @props.subject_index
        onViewSubject = @props.onViewSubject
      }
        <LightBox subject_set={@state.subject_set} subject_index={subject_index} onSubject={@specificSelection}/>
    </div>
      { if @props.subject_set.subjects.length > 1 
        <div className="subject-set-nav">
          <ActionButton text="Previous" onClick={@advancePrevious} classes={if @props.subject_index == 0 then 'disabled' else ''}/>
          <ActionButton text="Next" onClick={@advanceNext} classes={if @props.subject_index == @props.subject_set.subjects.length-1 then 'disabled' else ''} />
        </div>
      }
      { for subject, index in @props.subject_set.subjects
        <SubjectViewer
          key={index}
          subject={subject}
          workflow={@props.workflow}
          task={@props.task}
          annotation={@props.annotation}
          active={index == @props.subject_index}
          onComplete={@props.onComplete}
          onChange={@props.onChange}
        />
      }
    </div>

window.React = React

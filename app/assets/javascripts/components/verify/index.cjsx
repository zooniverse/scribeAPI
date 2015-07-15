# @cjsx React.DOM
React              = require 'react'
SubjectViewer      = require '../subject-viewer'
JSONAPIClient      = require 'json-api-client' # use to manage data?
FetchSubjectsMixin = require 'lib/fetch-subjects-mixin'
ForumSubjectWidget = require '../forum-subject-widget'

BaseWorkflowMethods     = require 'lib/workflow-methods-mixin'

# Hash of core tools:
coreTools          = require 'components/core-tools'

# Hash of transcribe tools:
verifyTools   = require './tools'

API                = require '../../lib/api'

module.exports = React.createClass # rename to Classifier
  displayName: 'Verify'
  mixins: [FetchSubjectsMixin, BaseWorkflowMethods] # load subjects and set state variables: subjects,  classification

  getDefaultProps: ->
    workflowName: 'verify'

  getInitialState: ->
    taskKey:                      null
    classifications:              []
    classificationIndex:          0
    subject_index:                0

  componentWillMount: ->
    @beginClassification()

  fetchSubjectsCallback: ->
    @setState taskKey: @getCurrentSubject().type if @getCurrentSubject()?

  # Handle user selecting a pick/drawing tool:
  handleDataFromTool: (d) ->
    classifications = @state.classifications
    currentClassification = classifications[@state.classificationIndex]

    currentClassification.annotation[k] = v for k, v of d

    @forceUpdate()
    @setState classifications: classifications, => @forceUpdate()

  handleTaskComplete: (d) ->
    @handleDataFromTool(d)
    @commitClassificationAndContinue d

  render: ->
    currentAnnotation = @getCurrentClassification().annotation

    onFirstAnnotation = currentAnnotation?.task is @activeWorkflow().first_task

    # console.log "viewer size: ", @state.viewerSize
    <div className="classifier">
      <div className="subject-area">
        { if ! @getCurrentSubject()?
            style = marginTop: "50px"
            <p style={style}>There are currently no {@props.workflowName} subjects. Try <a href="/#/mark">marking</a> instead!</p>

          else if @getCurrentSubject()?
            <SubjectViewer onLoad={@handleViewerLoad} subject={@getCurrentSubject()} active=true workflow={@activeWorkflow()} classification={@props.classification} annotation={currentAnnotation}>
              { if ( VerifyComponent = @getCurrentTool() )?
                
                <VerifyComponent
                  viewerSize={@state.viewerSize}
                  task={@getCurrentTask()}
                  annotation={@getCurrentClassification().annotation}
                  subject={@getCurrentSubject()}
                  onChange={@handleTaskComponentChange}
                  onComplete={@handleTaskComplete}
                  workflow={@activeWorkflow()}
                />
              }
            </SubjectViewer>
        }
      </div>

      { if @getCurrentSubject()?
          <div style={display: "none"} className="task-area">

            <div className="task-container">
              <nav className="task-nav">
                <button type="button" className="back minor-button" disabled={onFirstAnnotation} onClick={@destroyCurrentAnnotation}>Back</button>
                { if nextTask?
                    <button type="button" className="continue major-button" onClick={@advanceToTask.bind(@, nextTask)}>Next</button>
                  else
                    <button type="button" className="continue major-button" onClick={@completeClassification}>Done</button>
                }
              </nav>
            </div>

            <div className="forum-holder">
              <ForumSubjectWidget subject_set=@getCurrentSubject() />
            </div>

          </div>
      }
    </div>

window.React = React

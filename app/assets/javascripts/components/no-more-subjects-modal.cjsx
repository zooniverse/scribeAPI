React           = require 'react'
DraggableModal  = require 'components/draggable-modal'
GenericButton   = require 'components/buttons/generic-button'

module.exports = React.createClass
  displayName: 'NoMoreSubjectsModal'

  getDefaultProps: ->
    header:           'Nothing more to do here'

  propTypes:
    project:          React.PropTypes.object.isRequired
    header:           React.PropTypes.string.isRequired
    workflowName:     React.PropTypes.string.isRequired

  render: ->
    next_workflow = @props.project.workflowWithMostActives @props.workflowName
    next_href = "/"
    next_label = 'Continue'

    if next_workflow?
      next_href = "/#/" + next_workflow.name

    else if @props.project.downloadable_data
      next_href = "/#/data"
      next_label = "Explore Data"
      
    <DraggableModal
      header          = {@props.header}
      buttons         = {<GenericButton label={next_label} href={next_href} />}
    >
      { if next_workflow?
          <p>
            Currently, there are no {@props.project.term('subject')}s for you to {@props.workflowName}.
            Try <a href={next_href}>{next_workflow.name.capitalize()}</a> instead!
          </p>
     
        else
          <div>
            <p>There's nothing more to transcribe in {@props.project.title}!!  🎉 🎉 🎉
            </p>
            <p>Thank you to all the amazing volunteers who worked on this project.</p>
            
            { if @props.project.downloadable_data 
              <p>The {@props.project.root_subjects_count.toLocaleString()} records can be explored via the <a href="/#/data">Data tab</a>.</p>
            }
          </div>
      }
    </DraggableModal>


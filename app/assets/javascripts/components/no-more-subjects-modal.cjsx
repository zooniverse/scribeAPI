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
    if next_workflow?
      next_href = "/#/" + next_workflow.name

    <DraggableModal
      header          = {@props.header}
      buttons         = {<GenericButton label='Continue' href={next_href} />}
    >
      Currently, there are no {@props.project.term('subject')}s for you to {@props.workflowName}.
      { if next_workflow?
          <span> Try <a href={next_href}>{next_workflow.name.capitalize()}</a> instead!</span>
        else
          <span> Looks like there's no work do do right now. Please come back later.</span>
      }
    </DraggableModal>


React = require 'react'
API   = require '../lib/api'

SmallButton   = require('components/buttons/small-button')

GroupBrowser = React.createClass
  displayName: 'GroupBrowser'

  getInitialState:->
    groups:[]

  componentDidMount:->
    API.type("groups").get(project_id: @props.project.id).then (groups)=>
      group.showButtons = false for group in groups  # hide buttons by default
      @setState groups: groups

  showButtonsForGroup: (group, e) ->
    group.showButtons = true
    @forceUpdate() # trigger re-render to update buttons

  hideButtonsForGroup: (group, e) ->
    group.showButtons = false
    @forceUpdate() # trigger re-render to update buttons

  renderGroup: (group) ->
    # console.log 'renderGroup(): GROUP =  ', group
    buttonContainerClasses = []
    groupNameClasses = []
    if group.showButtons
      buttonContainerClasses.push "active"
    else
      groupNameClasses.push "active"

    console.log 'GROUP BACKGROUND: ', group.cover_image_url

    divStyle=
      backgroundImage: "url(#{group.cover_image_url})"
      backgroundSize: "300px"

    <div
      onMouseOver={@showButtonsForGroup.bind this, group}
      onMouseOut={@hideButtonsForGroup.bind this, group}
      className='group'
      style={divStyle} >
      <div className="button-container #{buttonContainerClasses.join ' '}">
        { for workflow in @props.project.workflows
            if (group.stats.workflow_counts?[workflow.id]?.active_subjects ? 0) > 0
              <a href={"/#/#{workflow.name}?group_id=#{group.id}"} className="button small-button">{workflow.name.capitalize()}</a>
        }
        <a href="/#/groups/#{group.id}" className="button small-button ghost">More info</a>
      </div>
      <p className="group-name #{groupNameClasses.join ' '}">{group.name}</p>
    </div>

  render: ->
    # Only display GroupBrowser if more than one group defined:
    return null if @state.groups.length <= 1

    console.log 'GROUPS: ', @state.groups
    groups = [@renderGroup(group) for group in @state.groups]
    <div>
      <h3 className="groups-header"><span>Select a {@props.project.term('group')}</span></h3>
      <div className="groups">
        {groups}
      </div>
    </div>

module.exports = GroupBrowser

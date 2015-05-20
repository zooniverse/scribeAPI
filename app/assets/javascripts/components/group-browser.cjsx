# @cjsx React.DOM

React = require 'react'
API   = require '../lib/api'

GroupBrowser = React.createClass
  displayName: 'GroupBrowser'

  getInitialState:->
    groups:[]

  componentDidMount:->
    console.log('getting groups')
    API.type("groups").get(project_id: @props.project.id).then (groups)=>
      console.log('got groups', groups )
      @setState
        groups: groups

  render:->
    groups  = [@renderGroup(group) for group in @state.groups]
    <div>
      <h3>Select a group</h3>

      <div className="groups">
        {groups}
      </div>
    </div>

  renderGroup:(group)->
    <div className='group' >
      <a href={"/#/groups/#{group.id}"}>
        <img src={group.cover_image_url}></img>
        <p>{group.name}</p>
      </a>
    </div>

module.exports = GroupBrowser

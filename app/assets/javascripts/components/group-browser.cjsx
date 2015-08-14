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
    divStyle=
      backgroundColor: "red"
      backgroundImage: "url(#{group.cover_image_url})"
      backgroundSize: "300px"

    <div className='group' style={divStyle}>
      <div className="button-container">
        <a className="button small-button">Mark</a>
        <a className="button small-button">Transcribe</a>
        <a className="button small-button ghost">More info</a>
      </div>
    </div>

module.exports = GroupBrowser

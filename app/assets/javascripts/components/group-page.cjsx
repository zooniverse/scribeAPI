React         = require("react")
GroupBrowser  = require('./group-browser')
ActionButton  = require('./action-button')
API           = require('../lib/API')

GroupPage = React.createClass
  displayName: "GroupPage"

  getInitialState:->
    console.log("GROUP PAGE ")
    group: null
    loading: false

  componentDidMount:->
    @setState
      loading: true

    API.type("groups").get(@props.params.group_id).then (group)=>
      console.log "GROUP ", group
      @setState
        group: group
        loading: false


  render:->
    if @state.loading
      <div className="group-page">
        <h2>Loading...</h2>
      </div>
    else if @state.group
      <div className='main-content'>
        <div className="group-page">
          <h1>{@state.group.name}</h1>
          <p>{@state.group.description}</p>

          <img src={@state.group.cover_image_url}></img>

          {@state.group.image}

          <div className='subject_sets'>
            {@renderSubjectSets()}
          </div>

          <ActionButton text="Random"></ActionButton>
        </div>
      </div>
    else
      <h2>Something went wrong</h2>

  renderSubjectSets:->
    [@renderSubjectSet(subject_set) for subject_set in @state.group.subject_sets]

  renderSubjectSet:(set)->
    <div className="subject_set">

      <img src={set.thumbnail}></img>
      <p>{set.state}</p>
      <a href={"#/mark/#{set.id}"}>Mark</a>
      <a href={"#/transcribe/#{set.id}"}>Transcribe</a>
    </div>


module.exports = GroupPage

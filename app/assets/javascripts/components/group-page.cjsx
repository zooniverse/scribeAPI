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

          <dl className="metadata-list">
            { for k,v of @state.group.meta_data when ['key','description','cover_image_url','external_url','retire_count'].indexOf(k) < 0
                # Is there another way to return both dt and dd elements without wrapping?
                <span>
                  <dt>{k.replace(/_/g, ' ')}</dt>
                  <dd>{v}</dd>
                </span>
            }
            { if @state.group.meta_data.external_url?
              <span>
                <dt>External Resource</dt>
                <dd><a href={@state.group.meta_data.external_url} target="_blank">{@state.group.meta_data.external_url}</a></dd>
              </span>
            }
          </dl>

          <img src={@state.group.cover_image_url}></img>

          {@state.group.image}

          <div className='subject_sets'>
            {@renderSubjectSets()}
          </div>

        </div>
      </div>
    else
      <h2>Something went wrong</h2>

  renderSubjectSets:->
    [@renderSubjectSet(subject_set) for subject_set in @state.group.subject_sets]

  renderSubjectSet:(set)->
    <div className="subject_set">

      <img src={set.thumbnail} />
      <div className="mark-transcribe-buttons">
        <ActionButton text="Mark" href={"#/mark/#{set.id}"} />
        <ActionButton text="Transcribe" href={"#/transcribe/#{set.id}"} />
      </div>
    </div>


module.exports = GroupPage

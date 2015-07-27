React         = require("react")
GroupBrowser  = require('./group-browser')
SmallButton   = require('components/buttons/small-button')
API           = require('../lib/api')

GroupPage = React.createClass
  displayName: "GroupPage"

  getInitialState:->
    console.log("GROUP PAGE ")
    group: null
    loading: false

  componentDidMount:->
    @setState
      loading: true

    console.log "props: ", @props
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
      <div className='page-content'>
        <div className="group-page">

          <img className="group-image" src={@state.group.cover_image_url}></img>

          <h1>{@state.group.name}</h1>
          <p>{@state.group.description}</p>

          <dl className="metadata-list">
            { for k,v of @state.group.meta_data when ['key','description','cover_image_url','external_url','retire_count'].indexOf(k) < 0
                # Is there another way to return both dt and dd elements without wrapping?
                <span key={k}>
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

          <div className='subject_sets'>
            { for set, i in @state.group.subject_sets
                <div key={i} className="subject_set">

                  <img src={set.thumbnail} />
                  <div className="mark-transcribe-buttons">
                    <SmallButton label="Mark" href={"#/mark/#{set.id}"} />
                    <SmallButton label="Transcribe" href={"#/transcribe/#{set.id}"} />
                  </div>
                </div>
            }
          </div>

        </div>
      </div>
    else
      <h2>Something went wrong</h2>


module.exports = GroupPage

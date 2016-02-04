React = require 'react'
API   = require '../lib/api'

module.exports = React.createClass
  displayName: 'FinalSubjectAssertion'
 
  propTypes: ->
    assertion:    React.PropTypes.object.isRequired

  getInitialState: ->
    showingRegion: false

  toggleRegion: (e) ->
    console.log "show: ", ! @state.showingRegion
    @setState showingRegion: ! @state.showingRegion

  render: ->
    <div>
      <h3>{@props.assertion.name}</h3>

      <ul className="assertion-data">
      { for k of @props.assertion.data
          <li key={k}>
            <span className="value">{@props.assertion.data[k]}</span>
            { if k != 'value'
                <span className="data-key">({k.replace /_/g, ' '})</span>
            }
          </li>
      }
      </ul>
      <dl className="assertion-properties">
        <dt>Confidence</dt>
        <dd>{Math.round(100 * @props.assertion.confidence)}%</dd>
        <dt>Status</dt>
        <dd>{@props.assertion.status.replace /_/, ' '}</dd>
        <dt>Distinct Transcriptions</dt>
        <dd>{@props.assertion.versions?.length || 0}</dd>
      </dl>
      <a className="show-region-link" href="javascript:void(0);" onClick={@toggleRegion}>
      { if @state.showingRegion
          <span>Hide {@props.project.term('mark')}</span>
        else
          <span>Show {@props.project.term('mark')}</span>
      }
      </a>
      {
        viewer_width = @props.assertion.region.width
        scale = viewer_width / @props.assertion.region.width
        s =
          background: "url(#{@props.subject.location.standard}) no-repeat -#{Math.round(@props.assertion.region.x * scale)}px -#{Math.round(@props.assertion.region.y * scale)}px"
          width: viewer_width + 'px'
          height: (if @state.showingRegion then Math.round(@props.assertion.region.height * scale) else 0) + 'px'
        classes = ['image-crop']
        classes.push 'showing' if @state.showingRegion
        <div className={classes.join ' '} image-crop" src={@props.subject.location.standard} style={s} />
      }
    </div>

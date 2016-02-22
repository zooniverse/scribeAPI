React                     = require("react")
FetchProjectMixin         = require 'lib/fetch-project-mixin'

module.exports = React.createClass
  displayName: "GenericPage"

  mixins: [FetchProjectMixin]

  getInitialState: ->
    project:          null

  getDefaultProps: ->
    key:              null
    title:            null
    content:          null
    nav:              null
    footer:           null
    current_nav:      location.hash

  propTypes:
    title:            React.PropTypes.string
    content:          React.PropTypes.string
    nav:              React.PropTypes.string
    footer:           React.PropTypes.string

  # Returns true if given nav link href appears to link to this page
  isCurrentNavLink: (href) ->
    # Known limitation: This will will assume equivalency of two URLs that don't have hashes
    # But use of the nav assumes hashes. A nav item really shouldn't link to a different domain/ctrl endpoint
    href.replace(/.*#/, '') == @props.current_nav.replace(/.*#/,'')

  componentDidMount: ->
    # Find nav link matching @props.current_nav
    matching = (el for el in $(React.findDOMNode(this)).find('.custom-page-nav li a') when @isCurrentNavLink($(el).attr('href')) )
    $(matching[0]).parent('li').addClass('current') if matching.length > 0

  htmlContent: ->
    content = @props.content

    replacements =
      "project.classification_count":         @state.project?.classification_count ? '__'
      "project.latest_export.created_at":     @state.project?.latest_export?.created_at ? '__'
      "project.root_subjects_count":          @state.project?.root_subjects_count ? '__'
      "project.title":                        @state.project?.title ? '__'

    for pattern, replacement of replacements
      pattern = new RegExp("{{#{pattern}}}", 'gi')

      # assume, if it's an int, we want to comma format it:
      if typeof(replacement) == 'number'
        replacement = replacement.toLocaleString()
      # If it's a date, parse it and make it human:
      if replacement.match /^\d{4}-\d{2}/
        replacement = moment(replacement, moment.ISO_8601).calendar()

      content = content.replace pattern, replacement

    marked(content)

  render: ->

    <div className="page-content custom-page" id="#{@props.key}">
      <h1>{@props.title}</h1>
      <div className="custom-page-inner-wrapper #{ if @props.nav? then 'with-nav' else '' }">
        { if @props.nav
            <div ref="nav" className="custom-page-nav" dangerouslySetInnerHTML={{ __html: marked @props.nav }} />
        }
        { if @props.content?
            <div className="custom-page-body" dangerouslySetInnerHTML={{__html: @htmlContent()}} />
        }
        { @props.children if @props.children? }
      </div>
      <div className="updated-at">{@props.footer}</div>
    </div>


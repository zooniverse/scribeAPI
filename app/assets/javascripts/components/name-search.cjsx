React         = require 'react'
{Navigation}  = require 'react-router'

NameSearch = React.createClass
  displayName: "NameSearch"
  mixins: [Navigation]

  # fieldKey: ->
  #   if @props.standalone
  #     'value'
  #   else
  #     @props.annotation_key

  handleKeyPress: (e) -> 

    console.log "e.target.value", e.target.value
    if @isMounted()
      term = e.target.value
      el = $(React.findDOMNode(this))
      el.autocomplete
        source: (request, response)=>
          $.ajax
            url: "/subject_sets/terms/#{term}"
            dataType: "json"
            data:
              q: request.term
            success: ( data ) =>
              names = []
              for n in data
                unit = {}
                unit["label"] =  n.meta_data.name
                unit["value"] = n
                names.push unit
              response( names )
            error: (xhr, thrownError)=>
              console.log xhr.status, thrownError
        focus: (e,ui)=>
          e.preventDefault()

        select: (e, ui) =>
          console.log "select event", event
          console.log "this", $("this")
          console.log "UI", ui
          @transitionTo 'mark', {},
            subject_set_id: ui.item.value.id
            page: 1

  handleChange:(e) ->





  render: ->
    <input id="name-search" type="text" onKeyDown={@handleKeyPress} onChange={@handleChange} />

module.exports = NameSearch
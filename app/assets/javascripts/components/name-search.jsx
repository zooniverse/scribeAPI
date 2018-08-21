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

    if @isMounted()
      term = e.target.value
      el = $(React.findDOMNode(this))
      el.autocomplete
        source: (request, response)=>
          $.ajax
            url: "/subject_sets/terms/#{@props.field}"
            dataType: "json"
            data:
              q: request.term
            success: ( data ) =>
              names = []
              if data.length != 0
                for n in data
                  unit = {}
                  unit["label"] =  n.meta_data.name
                  unit["value"] = n
                  names.push unit
              else
                unit = {}
                unit["label"] =  "Currently, there is no match. Please check back in a few days."
                names.push unit
              response( names )
            error: (xhr, thrownError)=>
              console.log xhr.status, thrownError
        focus: (e,ui)=>
          e.preventDefault()

        select: (e, ui) =>
          e.target.value
          @transitionTo 'mark', {},
            subject_set_id: ui.item.value.id
           

  render: ->
    <input id="name-search" type="text" placeholder={"Search Records by Name"} onKeyDown={@handleKeyPress} />

module.exports = NameSearch

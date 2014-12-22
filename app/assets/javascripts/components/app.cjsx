# @cjsx React.DOM

# React = require 'react'
{Router, Routes, Route, Link} = require 'react-router'
# require components here:

DynamicRouter      = require './dynamic-router'

# this would come from an endpoint
project = 
  workflow:
    mark: null
    transcribe:
      steps: [
          {
            key: 0,
            type: 'date', # type of input
            field_name: 'date',
            label: 'Date',
            instruction: 'Please type-in the log date.'
          },
          {
            key: 1,
            type: 'text',
            field_name: 'journal_entry',
            label: 'Journal Entry',
            instruction: 'Please type-in the journal entry for this day.'
          },
          {
            key: 2,
            type: 'textarea',
            field_name: 'other_entry',
            label: 'Other Entry',
            instruction: 'Type something, anything.'
          }
      ]
  pages: [
    {
      name:    'info', 
      content: 'I am a content thingie'
    },
    {
      name:    'science', 
      content: 'I am science'
    }
  ]

App = React.createClass
  displayname: 'app'

  render: ->
    <div>
      <div className="readymade-site-background">
        <div className="readymade-site-background-effect"></div>
      </div>
      <DynamicRouter project= {project} />
    </div>
module.exports = App

API                           = require './api'
Project                       = require 'models/project.coffee'

module.exports =
  componentDidMount: ->
    API.type('projects').get('current').then (result) =>
      @setState project: new Project(result)

 

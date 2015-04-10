JSONAPIClient = require 'json-api-client'

PATH_TO_API_ROOT = "#{window.location.protocol}//#{window.location.host}/" # 'http://localhost:3000/'

DEFAULT_HEADERS =
  'Content-Type': 'application/json'
  'Accept': 'application/vnd.api+json; version=1'

client = new JSONAPIClient PATH_TO_API_ROOT, DEFAULT_HEADERS

module.exports =client

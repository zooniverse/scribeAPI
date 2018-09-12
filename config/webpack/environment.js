const { environment } = require('@rails/webpacker')
const merge = require('webpack-merge')
const webpack = require('webpack')

// Add an additional plugin of your choosing : ProvidePlugin
environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  JQuery: 'jquery',
  jquery: 'jquery'
}))

module.exports = environment
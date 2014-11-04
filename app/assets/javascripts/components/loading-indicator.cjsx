# @cjsx React.DOM


LoadingIndicator = React.createClass
  displayName: 'LoadingIndicator'

  render: ->
    <span className="loading-indicator">
      Loading
      <span>•</span>
      <span>•</span>
      <span>•</span>
    </span>

window.LoadingIndicator = LoadingIndicator

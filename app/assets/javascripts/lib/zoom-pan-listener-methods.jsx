module.exports =
  getInitialState: ->
    zoomPanViewBox: null

  handleZoomPanViewBoxChange: (viewBox) ->
    @setState zoomPanViewBox: viewBox

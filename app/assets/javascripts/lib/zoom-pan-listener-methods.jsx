/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
export default {
  getInitialState() {
    return {
      zoomPanViewBox: null
    };
  },

  handleZoomPanViewBoxChange(viewBox) {
    return this.setState({ zoomPanViewBox: viewBox });
  }
};

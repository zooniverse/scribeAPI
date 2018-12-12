/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

// Disable text selection on matched el:
//   e.g. $('.draggable-element').disableSelection()
// From: http://stackoverflow.com/questions/4083351/what-does-jquery-fn-mean
import jQuery from 'jquery'
($ => {
  return ($.fn.disableSelection = function() {
    return this.attr("unselectable", "on")
      .css("user-select", "none")
      .on("selectstart", false);
  });
})(jQuery);

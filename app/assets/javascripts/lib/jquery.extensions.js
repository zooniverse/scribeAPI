
# Disable text selection on matched el:
#   e.g. $('.draggable-element').disableSelection()
# From: http://stackoverflow.com/questions/4083351/what-does-jquery-fn-mean

(($) =>
  $.fn.disableSelection = ->
    @.attr('unselectable', 'on').css('user-select', 'none').on('selectstart', false)
)(jQuery)



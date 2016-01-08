$(document).ready ->
  $(document).on 'click', '.left-arrow, .right-arrow', ->
    $.ajax
      type: 'GET'
      url: $(this).data('url')

$(document).ready ->

  $(document).on 'click', '.steps_table_link', ->
    $.ajax
      type: 'POST'
      url: '/service_requests/increment_click_counter'
$(document).ready ->
  $(document).on 'click', '.schedule_tabs a', (e) ->
    e.preventDefault()

    url = $(this).attr("data-url")
    href = this.hash
    pane = $(this)

    # ajax load from data-url
    $.ajax
      type: 'GET'
      url: url
      dataType: 'html'
      success: (data) ->
        $(href).html data
        pane.tab('show')

  # load first tab content
  $('#service_calendar .tab-content .tab-pane.active').load $('#service_calendar .active a').attr("data-url"), (result) ->
    $('#service_calendar .active a').tab('show')

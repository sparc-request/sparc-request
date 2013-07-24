$(document).ready ->

  $(document).on('change', '.clinical_select_data', ->
    $('#visit_form .spinner_wrapper').show()
    visit_name = $('option:selected', this).attr('data-appointment_id')
    setTimeout((->
      $('#visit_form .study_tracker_table').hide()
      $("table[data-appointment_table=#{visit_name}]").css("display", "table")
      $('#visit_form .spinner_wrapper').hide()
    ), 250)
  )

  $(document).on('click', '.clinical_tab_data', ->
    clicked = $(this)
    $('#visit_form .spinner_wrapper').show()
    core_name = $(this).attr('id')
    setTimeout((->
      $('.cwf_tabs li.ui-state-active').removeClass('ui-state-active')
      clicked.parent('li').addClass('ui-state-active')
      $('#visit_form .study_tracker_table tbody tr.fields').hide()
      if clicked.attr('data-has_access') == "false"
        $("." + core_name).find('input').prop('disabled', true)
      $("." + core_name).css("display", "table-row")
      $('#visit_form .spinner_wrapper').hide()
    ), 250)
  )
  
  $('#ssr_save').button()

  $('#ssr_save').on 'click', -> 
    routing = $('#ssr_routing').val()
    ssr_id = $('#ssr_routing').data('ssr_id')
    $.ajax
      type: "PUT"
      url: "/study_tracker/sub_service_requests/#{ssr_id}"
      data: { "sub_service_request[routing]": routing }
    return false

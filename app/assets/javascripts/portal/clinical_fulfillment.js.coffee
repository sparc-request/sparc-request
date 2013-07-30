$(document).ready ->

  $(document).on('change', '.clinical_select_data', ->
    $('#visit_form .spinner_wrapper').show()
    visit_name = $('option:selected', this).attr('data-appointment_id')
    setTimeout((->
      $('#visit_form .appointment_wrapper').hide()
      $("div[data-appointment_table=#{visit_name}]").css("display", "block")
      $('#visit_form .spinner_wrapper').hide()
      recalc_subtotal()
    ), 250)
  )

  $(document).on('click', '.clinical_tab_data', ->
    clicked = $(this)
    $('#visit_form .spinner_wrapper').show()
    core_name = $(this).attr('id')
    setTimeout((->
      $('.cwf_tabs li.ui-state-active').removeClass('ui-state-active')
      clicked.parent('li').addClass('ui-state-active')
      $('#visit_form .appointment_wrapper tbody tr.fields').hide()
      if clicked.attr('data-has_access') == "false"
        $("." + core_name).find('input').prop('disabled', true)
      $("." + core_name).css("display", "table-row")
      $('#visit_form .spinner_wrapper').hide()
      recalc_subtotal()
    ), 250)
  )
 
  recalc_subtotal = () ->
    subtotal = 0
    $('td.procedure_total_cell span:visible').each ->
      value = $(this).text()
      subtotal += parseFloat(value)  if not isNaN(value) and value.length isnt 0
    $('tr.grand_total_row td span').text(subtotal)

  $('#ssr_save').button()

  $('#ssr_save').on 'click', -> 
    routing = $('#ssr_routing').val()
    ssr_id = $('#ssr_routing').data('ssr_id')
    $.ajax
      type: "PUT"
      url: "/study_tracker/sub_service_requests/#{ssr_id}"
      data: { "sub_service_request[routing]": routing }
    return false

  $(document).on('click', '.add_comment_link', ->
    app_id = $(this).data('appointment_id')
    data =
      'appointment_id': app_id
      'body': $(".comment_box:visible").val()
    $.ajax
      type: 'POST'
      url:   "/study_tracker/appointments/add_note"
      data:  JSON.stringify(data)
      dataType: 'html'
      contentType: 'application/json; charset=utf-8'
      success: (html) ->
        console.log("In Success Function")
        console.log(html)
        $('.comments:visible').html(html)
  )
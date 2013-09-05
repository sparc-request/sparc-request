$(document).ready ->


  ####Triggers:
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
    $.cookie('current_core', core_name.replace('core_', ''), {path: '/', expires: 1})
    setTimeout((->
      $('.cwf_tabs li.ui-state-active').removeClass('ui-state-active')
      clicked.parent('li').addClass('ui-state-active')
      $('.hidden_by_tabs').hide()

      if clicked.attr('data-has_access') == "false"
        $("." + core_name).find('input').prop('disabled', true)

      $("." + core_name).css("display", "table-row")
      $('#visit_form .spinner_wrapper').hide()
      recalc_subtotal()
    ), 250)
  )

  $(document).on('click', '.check_box_cell input', ->
    recalc_row_totals()
    recalc_subtotal()
  )

  $(document).on('change', '.r_qty_cell input', ->
    recalc_row_totals()
    recalc_subtotal()
  )

  $(document).on('change', '.hasDatepicker', ->
    recalc_subtotal()
  )

  $(document).on('change', 'form.edit_subject', ->
    $('#save_alert').show()
  )

  $(document).on('click', '.cwf_add_service_button', ->
    $('#visit_form .spinner_wrapper').show()
    box = $(this).siblings('select')
    appointment_index = $('.new_procedure_wrapper:visible').data('appointment_index')
    procedure_index = $('.appointment_wrapper:visible tr.fields:visible').size()
    data =
      'appointment_id': box.data('appointment_id')
      'service_id': box.val()
      'appointment_index': appointment_index
      'procedure_index': procedure_index

    $.ajax
      type: "post"
      url: "/study_tracker/appointments/add_service"
      data: JSON.stringify(data)
      dataType: 'html'
      contentType: 'application/json; charset=utf-8'
      success: (response_html) ->
        $('.new_procedure_wrapper:visible').replaceWith(response_html)
        $('tr.grand_total_row:visible').before("<tr class='new_procedure_wrapper' data-appointment_index='#{appointment_index}'></tr>")
        $('#visit_form .spinner_wrapper').hide()
    return false
  )


  ####Totals functions:
  recalc_row_totals = () ->
    $('td.unit_cost_cell:visible').each ->
      if $(this).siblings("td.check_box_cell").children("input[type=checkbox]").prop('checked')
        #Do calculations, and set the correct totall
        unit_cost = $(this).text().replace('$', '')
        r_qty = $(this).siblings('td.r_qty_cell').children('input').val()
        total = unit_cost * r_qty
        $(this).siblings('td.procedure_total_cell').text('$' + commaSeparateNumber(total.toFixed(2)))
      else
        #Set to zero
        $(this).siblings('td.procedure_total_cell').text('$0.00')

  recalc_subtotal = () ->
    if $('.hasDatepicker:visible').val()
      subtotal = 0
      $('td.procedure_total_cell:visible').each ->
        value = $(this).text().replace('$', '')
        subtotal += parseFloat(value)  if not isNaN(value) and value.length isnt 0
      $('tr.grand_total_row td.grand_total_cell').text('$' + commaSeparateNumber(subtotal.toFixed(2)))
    else
      $('tr.grand_total_row td.grand_total_cell').text('$0.00')


  ####Comments Logic:
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
        $('.comments:visible').html(html)
  )


  ####Sub Service Request Save button
  $('#ssr_save').button()

  $('#ssr_save').on 'click', -> 
    routing = $('#ssr_routing').val()
    ssr_id = $('#ssr_routing').data('ssr_id')
    $.ajax
      type: "PUT"
      url: "/study_tracker/sub_service_requests/#{ssr_id}"
      data: { "sub_service_request[routing]": routing }
    return false


  ####Payments logic (Andrew)
  $(document).on "nested:fieldAdded:payments", (event) ->
    default_percent_subsidy = $('.payments_add_button').data('default-percent-subsidy')
    event.field.find(".new_percent_subsidy").val(default_percent_subsidy)


  ####Support Functions
  commaSeparateNumber = (val) ->
    while (/(\d+)(\d{3})/.test(val.toString()))
      val = val.toString().replace(/(\d+)(\d{3})/, '$1'+','+'$2')
    return val;
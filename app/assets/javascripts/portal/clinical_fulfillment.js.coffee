# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

$(document).ready ->

  check_core_permissions = () ->
    $('.clinical_tab_data').each ->
      if $(this).attr('data-has_access') == "false" 
        core_name = $(this).attr('href')
        $(core_name).find('input').prop('disabled', true)
        $(core_name).find('button').prop('disabled', true)

  check_core_permissions()
  # only submit data that has changed or is required for calculations

  $('.procedure_r_qty, .procedure_t_qty, .procedure_box').on 'change', ->
    $(this).addClass('changed_attr')

  $('.procedure_box').on 'change', ->
    $(this).parent('td').siblings().children('.procedure_r_qty').addClass('changed_attr')

  $("#save_appointments").click (event) ->
    $('.procedure_r_qty, .procedure_t_qty').not('.changed_attr').prop('disabled', true)

  # end submit data for changes/requirements

  $('#procedures_added_popup').dialog
    # dialogClass: "no-close"
    autoOpen: true
    # height: 80
    width: 350
    modal: true
    resizable: false
    close: -> delete_toast_message()

  delete_toast_message = () ->
    data =
      'id': $("#procedures_added_popup").attr('data-calendar_id')
    $.ajax
      type: 'POST'
      url:   "/clinical_work_fulfillment/calendars/delete_toast_messages"
      data:  JSON.stringify(data)
      dataType: 'html'
      contentType: 'application/json; charset=utf-8'

  $("#cwf_audit_start_date_input").datepicker
    altField: "#cwf_audit_start_date"
    altFormat: "yy-mm-dd"
    minDate: new Date($('#min_start_date').val())
    maxDate: new Date($('#max_end_date').val())
    onClose: (selectedDate) ->
      unless selectedDate == ''
        $('#cwf_audit_end_date_input').datepicker("option", "minDate", selectedDate)


  $("#study_tracker_billing_report_end_date_input").datepicker
    altField: "#study_tracker_billing_report_end_date"
    altFormat: "yy-mm-dd"
    onClose: (selectedDate) ->
      unless selectedDate == ''
        $('#study_tracker_billing_report_start_date_input').datepicker("option", "maxDate", selectedDate)
  
  $("#study_tracker_billing_report_start_date_input").datepicker
    altField: "#study_tracker_billing_report_start_date"
    altFormat: "yy-mm-dd"
    onClose: (selectedDate) ->
      unless selectedDate == ''
        $('#study_tracker_billing_report_end_date_input').datepicker("option", "minDate", selectedDate)


  $("#cwf_audit_end_date_input").datepicker
    altField: "#cwf_audit_end_date"
    altFormat: "yy-mm-dd"
    minDate: new Date($('#min_start_date').val())
    maxDate: new Date($('#max_end_date').val())
    onClose: (selectedDate) ->
      unless selectedDate == ''
        $('#cwf_audit_start_date_input').datepicker("option", "maxDate", selectedDate)

  ##Triggers:
  $(document).on('change', '.clinical_select_data', ->
    $('#processing_request').show()
    data =
      'visit_group_id': $('option:selected', this).data('visit_group_id')
      'sub_service_request_id': $('#sub_service_request_id').val()
      'calendar_id': $("#calendar_id").val()
      'appointment_tag': $('option:selected', this).val()
    $.ajax
      type: 'POST'
      url: '/clinical_work_fulfillment/calendars/change_visit_group'
      data: JSON.stringify(data)
      dataType: 'script'
      contentType: 'application/json; charset=utf-8'
      success: ->
        $('#processing_request').hide()
        recalc_subtotal()
        check_core_permissions()
  )

  $(document).on('click', '.check_box_cell input', ->
    unit_factor = $(this).data('unit_factor')
    recalc_row_totals(unit_factor)
    recalc_subtotal()
  )

  $(document).on('change', '.r_qty_cell input', ->
    unit_factor = $(this).data('unit_factor')
    recalc_row_totals(unit_factor)
    recalc_subtotal()
  )

  $(document).on('change', '.hasDatepicker', ->
    recalc_subtotal()
  )

  $(document).on('change', 'form.edit_subject', ->
    $('.save_alert').show()
  )

  $(document).on('click', '.clinical_tab_data', ->
    check_core_permissions()
    recalc_subtotal()
  )

  # Save Alert popups

  #Subject Calendars:
  $(document).on('change', '#patient_visit_calendar form.edit_subject', ->
    confirmExit = ->
      "Changes to patient calendars need to be saved, click 'Stay on page' and save the form to save the calendar, or click 'Leave page' to leave the page and dismiss your changes."
    window.onbeforeunload = confirmExit
  )

  $(document).on('click', '#patient_visit_calendar form.edit_subject input#save_appointments', ->
    window.onbeforeunload = null
  )

  #Subject Info
  $(document).on('change', '#subjects form.edit_study', ->
    confirmExit = ->
      "Changes to subjects need to be saved. Click 'Cancel' to return to the page and save the form, or 'OK' to leave the page and dismiss your changes."
    window.onbeforeunload = confirmExit
  )

  $(document).on('click', 'form.edit_study input[type=submit]', ->
    window.onbeforeunload = null
  )


  $(document).on('click', 'a.check_all', ->
    if $('a.check_all span').hasClass('ui-icon-check')
      $('a.check_all span').removeClass('ui-icon-check').addClass('ui-icon-close')
      $('td.check_box_cell:visible input[type=checkbox]').not(":checked").click()
    else
      $('a.check_all span').removeClass('ui-icon-close').addClass('ui-icon-check')
      $('td.check_box_cell:visible input[type=checkbox]').filter(":checked").click()
    recalc_row_totals()
    recalc_subtotal()
    $('.save_alert').show()
  )

  $(document).on('click', '.dashboard_link', ->
    if $(this).hasClass('active')
      $(this).removeClass('active')
      $(this).text("-- Show Dashboard --")
    else
      $(this).addClass('active')
      $(this).text("-- Hide Dashboard --")

    $('#dashboard').slideToggle()
  )

  $(document).on('nested:fieldRemoved:fulfillments', (event) ->
    field = event.field
    field.addClass("deleted_by_nested_form")
  )

  $(document).on('nested:fieldAdded:fulfillments', (event) ->
    field = event.field
    field.siblings('.study_level_charges').not('.deleted_by_nested_form').show()
    field.siblings('.fulfillment_header').children('th').children('span').removeClass('ui-icon-triangle-1-e')
    field.siblings('.fulfillment_header').children('th').children('span').addClass('ui-icon-triangle-1-s')
    field.siblings('.fulfillment_header').removeClass('collapsed')
  )

  $(document).on('click', '.fulfillment_header', ->
    if $(this).hasClass('collapsed')
      $(this).siblings('.study_level_charges').not('.deleted_by_nested_form').show()
      $(this).removeClass('collapsed')
      $(this).children('th').children('span').removeClass('ui-icon-triangle-1-e')
      $(this).children('th').children('span').addClass('ui-icon-triangle-1-s')
    else
      $(this).siblings('.study_level_charges').hide()
      $(this).addClass('collapsed')
      $(this).children('th').children('span').removeClass('ui-icon-triangle-1-s')
      $(this).children('th').children('span').addClass('ui-icon-triangle-1-e')
  )

  $(document).on('click', '.cwf_add_service_button', ->
    $('#processing_request').show()
    box = $(this).siblings('select')
    appointment_index = $('.new_procedure_wrapper:visible').data('appointment_index')
    procedure_index = $('.appointment_wrapper:visible tr.fields:visible').size()
    ssr_id = $('#sub_service_request_id').val()
    data =
      'appointment_id': box.data('appointment_id')
      'service_id': box.val()
      'appointment_index': appointment_index
      'procedure_index': procedure_index
      'sub_service_request_id': ssr_id

    $.ajax
      type: "post"
      url: "/clinical_work_fulfillment/appointments/add_service"
      data: JSON.stringify(data)
      dataType: 'html'
      contentType: 'application/json; charset=utf-8'
      success: (response_html) ->
        $('.new_procedure_wrapper:visible').replaceWith(response_html)
        $('tr.grand_total_row:visible').before("<tr class='new_procedure_wrapper' data-appointment_index='#{appointment_index}'></tr>")
        $('#processing_request').hide()
    return false
  )


  ####Totals functions:
  recalc_row_totals = (unit_factor) ->
    $('td.unit_cost_cell:visible').each ->
      if $(this).siblings("td.check_box_cell").children("input[type=checkbox]").prop('checked')
        #Do calculations, and set the correct totall
        unit_cost = $(this).text().replace('$', '').replace(/[ ,]/g, "")
        r_qty = $(this).siblings('td.r_qty_cell').children('input').val()
        kits = r_qty / unit_factor
        kits = Math.ceil(kits)
        total = unit_cost * kits
        $(this).siblings('td.procedure_total_cell').text('$' + commaSeparateNumber(total.toFixed(2)))
      else
        #Set to zero
        $(this).siblings('td.procedure_total_cell').text('$0.00')

  recalc_subtotal = () ->
    $('.study_tracker_table').each ->
      if $(this).find('.hasDatepicker').val()
        subtotal = 0
        $(this).find('td.procedure_total_cell').each ->
          value = $(this).text().replace('$', '').replace(/[ ,]/g, "")
          subtotal += parseFloat(value)  if not isNaN(value) and value.length isnt 0
        $(this).find('tr.grand_total_row td.grand_total_cell').text('$' + commaSeparateNumber(subtotal.toFixed(2)))
      else
        $(this).find('tr.grand_total_row td.grand_total_cell').text('$0.00')

  ####Prevent enter key on study_tracker_table
  $('.study_tracker_table input').keypress (event) ->
    charCode = event.charCode || event.keyCode
    if charCode == 13
      return false

  ####Comments Logic:
  $(document).on('click', '.add_comment_link', ->
    app_id = $(this).data('appointment_id')
    data =
      'appointment_id': app_id
      'body': $(".comment_box:visible").val()
    $.ajax
      type: 'POST'
      url:   "/clinical_work_fulfillment/appointments/add_note"
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
      url: "/clinical_work_fulfillment/sub_service_requests/#{ssr_id}"
      data: { "sub_service_request[routing]": routing }
    return false
  
  ####Sub Service Request Save button
  $('#protocol_billing_business_manager_static_email_save').button()

  $('#protocol_billing_business_manager_static_email_save').on 'click', -> 
    billing_business_manager_static_email = $('#protocol_billing_business_manager_static_email').val()
    protocol_id = $('#protocol_billing_business_manager_static_email').data('protocol_id')
    $.ajax
      type: "PUT"
      url: "/clinical_work_fulfillment/protocols/#{protocol_id}/update_billing_business_manager_static_email"
      data: { "protocol[billing_business_manager_static_email]": billing_business_manager_static_email }
    return false

  ####Validations for fulfillment fields within the Study Level Charges tab
  $(document).on('click', '.study_charges_submit', (event) ->
    $('.fulfillment_quantity:visible, .fulfillment_date:visible, .fulfillment_unit_quantity:visible').each (index, field) ->
      if ($(field).val() == "")
        event.preventDefault()
        $().toastmessage('showWarningToast', 'Date, quantity, and unit quantity are required fields.')
        return false
  )


  ####Payments logic (Andrew)
  $(document).on "nested:fieldAdded:payments", (event) ->
    default_percent_subsidy = $('.payments_add_button').data('default-percent-subsidy')
    event.field.find(".new_percent_subsidy").val(default_percent_subsidy)

  #Study level charges tab
  $('#cwf_one_time_fee_table .remove_nested_fields.fulfillments').qtip
    content:
      text: "Remove this fulfillment"
    position:
        corner:
          target: "topMiddle"
          tooltip: "bottomMiddle"
          
  ####Support Functions
  commaSeparateNumber = (val) ->
    while (/(\d+)(\d{3})/.test(val.toString()))
      val = val.toString().replace(/(\d+)(\d{3})/, '$1'+','+'$2')
    return val


  ####Subject search logic
  if $('.search-all-subjects').length > 0
    $('.search-all-subjects').autocomplete({
      source: JSON.parse($('.values_test').val())
      select: (event, ui) ->
        $('.subject').hide()
        $(".#{ui.item.id}").show()
      })

  $('.search-all-subjects').focus ->
    $(this).val('')

  $('.search-all-subjects').live('keyup', ->
    $('.subject').show() if $(this).val() is ''
  ).live('click', ->
    $('.subject').show() if $(this).val() is ''
  )


  #Research project summary report start and end date
  $("#rps_start_date").datepicker(dateFormat: "yy-mm-dd")
  $("#rps_end_date").datepicker(dateFormat: "yy-mm-dd")

  continue_with_research_project_summary_report = false
  $("#research_project_summary_report_date_range").dialog(autoOpen: false, dialogClass: "report_date_range")
  $(document).on 'click', '#research_project_summary_report_in_cwf', (event) ->
    if continue_with_research_project_summary_report == false
      $("#research_project_summary_report_date_range").dialog("open")
      event.preventDefault()
  
  $(document).on 'click', '#rps_continue', ->
    continue_with_research_project_summary_report = true
    start_date = $('#rps_start_date').val()
    end_date = $('#rps_end_date').val()
    href = $("#research_project_summary_report_in_cwf").attr("href")
    href = href + "?start_date=#{start_date}&end_date=#{end_date}"
    $("#research_project_summary_report_date_range").dialog("close")
    $('#processing_request').show()
    window.location.href = href

  #Methods for hiding and displaying the fulfillment headers in the Study Level Charges tab

  #Because of how nested forms work, the data attribute needs to be given here to get the correct id
  $(document).on 'click', 'a.add_nested_fields', ->
    otf_id = $(this).data('otf_id')
    $("tbody#cwf_fulfillment_#{otf_id}").find('a.remove_nested_fields').attr('data-otf_id', otf_id)


  $(document).on 'click', 'a.remove_nested_fields', ->
    otf_id = $(this).data('otf_id')
    nested_field_count = $(this).closest('.otf_service_tbody').find('a.remove_nested_fields:visible').length
    if nested_field_count == 0
      $(".fulfillments_#{otf_id}").toggle()

  #End of Study Level Charges Methods

  #Validation for deleting a subject with completed appointments
  $(document).on 'click', '.cwf_subject_delete', (event)->
    alert("This subject has one or more completed appointments and can't be deleted.")




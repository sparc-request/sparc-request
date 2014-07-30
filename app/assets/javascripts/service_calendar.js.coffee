#= require navigation
#= require constants

$(document).ready ->
  $('.visit_number a, .service_calendar_row').live 'click', ->
    $('.service_calendar_spinner').show()
  
  $('.line_item_visit_template').live 'change', ->
    $('.service_calendar_spinner').show()
    obj = $(this)
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&checked=#{$(this).is(':checked')}"
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          alert(error);
          obj.prop('checked', false)
    .complete =>
      $('.service_calendar_spinner').hide()
      arm_id = $(this).data("arm_id")
      calculate_max_rates(arm_id)

  $('.line_item_visit_quantity').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&qty=#{$(this).val()}"
    .complete =>
      $('.service_calendar_spinner').hide()

  $('.line_item_visit_billing').live 'change', ->
    intRegex = /^\d+$/

    my_qty = parseInt($(this).val(), 10)
    sibling_qty = 0

    $(this).siblings().each (i, element) ->
      sibling_qty += parseInt($(this).val(), 10)

    qty = my_qty + sibling_qty
    
    if intRegex.test qty
      unit_minimum = $(this).attr('data-unit-minimum')

      if qty > 0 and qty < unit_minimum
        alert "Quantity of #{qty} is less than the unit minimum of #{unit_minimum}.\nTotal quantity is being set to the unit minimum"
        my_qty = unit_minimum - sibling_qty
        $(this).val(my_qty)

      obj = $(this)
      original_val = obj.attr('previous_quantity')

      $('.service_calendar_spinner').show()
      $.ajax
        type: 'PUT'
        url: $(this).attr('update') + "&qty=#{my_qty}"
        success: ->
          $(obj).attr('previous_quantity', $(obj).val())
        error: (jqXHR, textStatus, errorThrown) ->
          if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
            errors = JSON.parse(jqXHR.responseText)
          else
            errors = [textStatus]
          for error in errors
            # May need to include something to allow error.humanize like we do elsewhere
            # if this gets weird looking.
            alert(error);
            $(obj).val(original_val)
            $(obj).attr('current_quantity', original_val)
      .complete =>
        $('.service_calendar_spinner').hide()
        arm_id = $(this).data("arm_id")
        calculate_max_rates(arm_id)
    else
      alert "Quantity must be a whole number"
      $('.service_calendar_spinner').hide()
      $(this).val(0)

  $('.line_items_visit_subject_count').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&qty=#{$(this).val()}"
    .complete ->
      $('.service_calendar_spinner').hide()

  $('.visit_name').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&name=#{$(this).val()}"
    .complete ->
      $('.service_calendar_spinner').hide()

  $(document).on('change', '.visit_day', ->
    # Grab the day
    position = $(this).data('position')
    day_val = $(this).val()
    original_val = $(this).data('day')
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update')
      data: {day: day_val, position: position}
      success: =>
        $(this).data('day', day_val)
        $().toastmessage('showSuccessToast', "Service request has been saved.");
    .error (event, request, test) =>
      alertText = stack_errors_for_alert(JSON.parse(event.responseText))
      alert(alertText)
      $(this).val(original_val)
    .complete ->
      $('.service_calendar_spinner').hide()
  )

  $('.visit_window').live 'change', ->
    # Grab the day
    position = $(this).data('position')
    window_val = $(this).val()
    original_val = $(this).data('window')
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update')
      data: {window: window_val, position: position}
      success: =>
        $(this).data('window', window_val)
        $().toastmessage('showSuccessToast', "Service request has been saved.");
    .error (event, request, test) =>
      alertText = stack_errors_for_alert(JSON.parse(event.responseText))
      alert(alertText)
      $(this).val(original_val)
    .complete ->
      $('.service_calendar_spinner').hide()

# Triggers for changing attributes on one time fee line items
  $('.units_per_quantity').live 'change', ->
    intRegex = /^\d+$/
    max = parseInt($(this).attr('data-qty_max'), 10)
    prev_qty = $(this).attr('current_units_per_quantity')
    user_input = parseInt($(this).val(), 10)
    
    # Handle errors
    unless intRegex.test user_input
      $(this).css({'border': '2px solid red'})
      $('#nan_error').fadeIn('fast').delay(5000).fadeOut(5000, => $(this).css('border', ''))
      $(this).val(prev_qty)
    else
      if user_input > max
        $(this).css({'border': '2px solid red'})
        $('#unit_quantity').html(user_input)
        $('#unit_max').html(max + ".")
        $('#unit_max_error').fadeIn('fast').delay(5000).fadeOut(5000, => $(this).css('border', ''))
        $(this).val(max)
      else
        $(this).attr('current_units_per_quantity', user_input)
        $('#unit_max_error').hide()
        $(this).css('border', '')
        # If it passes validation and is within study tracker, save by ajax
        if $(this).data('study_tracker') == true
          save_line_item_by_ajax(this)
        else
          update_otf_line_item this
    recalculate_one_time_fee_totals()
    return false

  $('.line_item_quantity').live 'change', ->
    intRegex = /^\d+$/
    unit_min = parseInt($(this).attr('unit_minimum'), 10)
    prev_qty = $(this).attr('current_quantity')
    qty = parseInt($(this).val(), 10)

    # Handle errors
    unless intRegex.test qty
      $(this).css({'border': '2px solid red'})
      $('#nan_error').fadeIn('fast').delay(5000).fadeOut(5000, => $(this).css('border', ''))
      $(this).val(prev_qty)
    else
      if qty < unit_min
        $(this).css({'border': '2px solid red'})
        $('#quantity').html(qty)
        $('#unit_minimum').html(unit_min + ".")
        $('#one_time_fee_errors').fadeIn('fast').delay(5000).fadeOut(5000, => $(this).css('border', ''))
        $(this).val(prev_qty)
      else
        $(this).attr('current_quantity', qty)
        $('#one_time_fee_errors').hide()
        $(this).css('border', '')
        # If it passes validation and is within study tracker, save by ajax
        if $(this).data('study_tracker') == true
          save_line_item_by_ajax(this)
        else
          update_otf_line_item this
    recalculate_one_time_fee_totals()
    return false

  $(document).on('click', '.move_visits', ->
    sr_id = $(this).data('sr_id')
    data =
      'arm_id': $(this).data('arm_id')
      'tab': $(this).data('tab')
      'portal': $(this).data('portal')
    $.ajax
      type: 'PUT'
      url: "/service_requests/#{sr_id}/service_calendars/show_move_visits"
      data: JSON.stringify(data)
      dataType: 'script'
      contentType: 'application/json; charset=utf-8'
  )

  $(document).on('change', '.jump_to_visit', ->
    $('.service_calendar_spinner').show()

    page = $(this).find('option:selected').attr('parent_page')

    if page == undefined || page == false
      page = $(this).val()

    $.ajax
      type: 'GET'
      url: $(this).attr('url')
      data: {"page": page}
      dataType: 'script'
      success: ->
        $('.service_calendar_spinner').hide()

  )

  update_otf_line_item = (obj) ->
    original_val = $(obj).attr('previous_quantity')
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(obj).attr('update') + "&val=#{$(obj).val()}"
      success: ->
        $(obj).attr('previous_quantity', $(obj).val())
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          # May need to include something to allow error.humanize like we do elsewhere
          # if this gets weird looking.
          alert(error);
          $(obj).val(original_val)
          $(obj).attr('current_quantity', original_val)
    .complete =>
      $('.service_calendar_spinner').hide()


# methods for saving one time fee attributes
  save_line_item_by_ajax = (obj) ->
      object_id = $(obj).data("line_item_id")
      name = $(obj).attr('name')
      key = name.replace("line_item_", '')
      data = {}
      data[key] = $(obj).val()
      put_attribute(object_id, data)


  put_attribute = (id, data) ->
    $.ajax
      type: 'PUT'
      url:  "/portal/admin/line_items/#{id}/update_from_cwf"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf-8'
      success: ->
        $().toastmessage('showSuccessToast', "Service request has been saved.")
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showErrorToast', "#{error.humanize()}.")

recalculate_one_time_fee_totals = ->
  grand_total = 0
  otfs = $('.otfs')

  otfs.each (index, otf) =>
    your_cost = $(otf).children('.your_cost').data('your_cost')
    qty = $(otf).find('.line_item_quantity').val()
    units_per_qty = $(otf).find('.units_per_quantity').val()
    if units_per_qty == undefined
      units_per_qty = 1
    unit_factor = $(otf).data('unit_factor')

    number_of_kits = (qty * units_per_qty) / unit_factor
    number_of_kits = Math.ceil(number_of_kits)
    new_otf_total = (number_of_kits * your_cost) / 100.0
    grand_total += new_otf_total
    
    $(otf).find('.otf_total').html('$' + commaSeparateNumber(new_otf_total.toFixed(2)))

  $('.otf_total_direct_cost').html('$' + commaSeparateNumber(grand_total.toFixed(2)))

commaSeparateNumber = (val) ->
  while (/(\d+)(\d{3})/.test(val.toString()))
    val = val.toString().replace(/(\d+)(\d{3})/, '$1'+','+'$2')
  return val;

stack_errors_for_alert = (errors) ->
  compiled = ''
  for error in errors
    compiled += error + '\n'
  return compiled

(exports ? this).calculate_max_rates = (arm_id) ->
  for num in [1..5]
    column = '.visit_column_' + num
    visits = $(column + '.visit' + '.arm_' + arm_id)
    direct_total = 0
    $(visits).each (index, visit) =>
      if $(visit).is(':hidden') == false && $(visit).data('cents')
        direct_total += Math.floor($(visit).data('cents')) / 100.0
    indirect_rate = parseFloat($("#indirect_rate").val()) / 100.0
    indirect_total = if use_indirect_cost == 'true' then direct_total * indirect_rate else 0
    max_total = direct_total + indirect_total

    direct_total_display = '$' + (direct_total).toFixed(2)
    indirect_total_display = '$' + (Math.floor(indirect_total * 100) / 100).toFixed(2)
    max_total_display = '$' + (Math.floor(max_total * 100) / 100).toFixed(2)

    $(column + '.max_direct_per_patient' + '.arm_' + arm_id).html(direct_total_display)
    $(column + '.max_indirect_per_patient' + '.arm_' + arm_id).html(indirect_total_display)
    $(column + '.max_total_per_patient' + '.arm_' + arm_id).html(max_total_display)

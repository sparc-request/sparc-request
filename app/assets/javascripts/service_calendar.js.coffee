#= require navigation
#= require constants

$(document).ready ->
  $('.visit_number a, .service_calendar_row').live 'click', ->
    $('.service_calendar_spinner').show()
  
  $('.line_item_visit_template').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&checked=#{$(this).is(':checked')}"
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

      $('.service_calendar_spinner').show()
      $.ajax
        type: 'PUT'
        url: $(this).attr('update') + "&qty=#{my_qty}"
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
    .error (event, request, test) =>
      alertText = stack_errors_for_alert(JSON.parse(event.responseText))
      alert(alertText)
      $(this).val(original_val)
    .complete ->
      $('.service_calendar_spinner').hide()

  $('.units_per_quantity').live 'change', ->
    max = parseInt($(this).attr('data-qty_max'), 10)
    user_input = parseInt($(this).val(), 10)
    if user_input > max
      $(this).css({'border': '2px solid red'})
      $('#unit_quantity').html(user_input)
      $('#unit_max').html(max + ".")
      $('#unit_max_error').fadeIn('fast').delay(5000).fadeOut(5000, => $(this).css('border', ''))
      $(this).val(max)
    else
      $('#unit_max_error').hide()
      $('#unit_max_error').css('border', '')
      $(this).css('border', '')
    recalculate_one_time_fee_totals()
    return false

  $('.line_item_quantity').live 'change', -> 
    unit_min = parseInt($(this).attr('unit_minimum'), 10)
    prev_qty = $(this).attr('current_quantity')
    qty = parseInt($(this).val(), 10)
    if qty < unit_min
      $(this).css({'border': '2px solid red'})
      $('#quantity').html(qty)
      $('#unit_minimum').html(unit_min + ".")
      $('#one_time_fee_errors').fadeIn('fast').delay(5000).fadeOut(5000, => $(this).css('border', ''))
      $(this).val(prev_qty)
    else
      $('#one_time_fee_errors').hide()
      $(this).css('border', '')
    recalculate_one_time_fee_totals()
    return false

recalculate_one_time_fee_totals = ->
  grand_total = 0
  otfs = $('.otfs')

  otfs.each (index, otf) =>
    your_cost = $(otf).children('.your_cost').data('your_cost')
    qty = $(otf).find('.line_item_quantity').val()
    units_per_qty = $(otf).find('.units_per_quantity').val()

    new_otf_total = Math.floor(your_cost * qty * units_per_qty) / 100.0
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

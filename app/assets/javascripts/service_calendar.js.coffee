#= require navigation
#= require constants

$(document).ready ->
  $('#service_calendar').tabs
    show: (event, ui) -> 
      $(ui.panel).html('<div class="ui-corner-all" style = "border: 1px solid black; padding: 25px; width: 200px; margin: 30px auto; text-align: center">Loading data....<br /><img src="/assets/spinner.gif" /></div>')
    select: (event, ui) ->
      $(ui.panel).html('<div class="ui-corner-all" style = "border: 1px solid black; padding: 25px; width: 200px; margin: 30px auto; text-align: center">Loading data....<br /><img src="/assets/spinner.gif" /></div>')

  $('.visit_number a, .service_calendar_row').live 'click', ->
    $('.service_calendar_spinner').show()
  
  $('.line_item_visit_template').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&checked=#{$(this).is(':checked')}"
    .complete =>
      $('.service_calendar_spinner').hide()
      calculate_max_rates()

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
        calculate_max_rates()
    else
      alert "Quantity must be a whole number"
      $('.service_calendar_spinner').hide()
      $(this).val(0)

  $('.line_item_visit_count').live 'change', ->
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
    
(exports ? this).calculate_max_rates = ->
  # TODO: Need to update this for the arms
  # for num in [1..5]
  #   column = '.visit_column_' + num
  #   visits = $(column + '.visit')
  #   direct_total = 0
  #   $(visits).each (index, visit) =>
  #     if $(visit).is(':hidden') == false && $(visit).data('cents')
  #       direct_total += Math.floor($(visit).data('cents')) / 100.0
  #   indirect_rate = parseFloat($("#indirect_rate").val()) / 100.0
  #   indirect_total = if use_indirect_cost == 'true' then direct_total * indirect_rate else 0
  #   max_total = direct_total + indirect_total

  #   direct_total_display = '$' + (direct_total).toFixed(2)
  #   indirect_total_display = '$' + (Math.floor(indirect_total * 100) / 100).toFixed(2)
  #   max_total_display = '$' + (Math.floor(max_total * 100) / 100).toFixed(2)

  #   $(column + '.max_direct_per_patient').html(direct_total_display)
  #   $(column + '.max_indirect_per_patient').html(indirect_total_display)
  #   $(column + '.max_total_per_patient').html(max_total_display)

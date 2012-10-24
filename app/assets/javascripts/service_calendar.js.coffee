#= require navigation

$(document).ready ->
  $('#service_calendar').tabs()
  
  $('.line_item_visit_template').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&checked=#{$(this).is(':checked')}"
    .complete =>
      $('.service_calendar_spinner').hide()
      calculate_max_rates($(this).parent())

  $('.line_item_visit_quantity').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&qty=#{$(this).val()}"
    .complete =>
      $('.service_calendar_spinner').hide()
      calculate_max_rates($(this).parent())

  $('.line_item_visit_billing').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&qty=#{$(this).val()}"
    .complete =>
      $('.service_calendar_spinner').hide()
      calculate_max_rates($(this).parent())

  $('.line_item_visit_count').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&qty=#{$(this).val()}"
    .complete ->
      $('.service_calendar_spinner').hide()

    
(exports ? this).calculate_max_rates = (parent) ->
  col_num = parent.attr('visit_column')
  column = '.visit_column_' + col_num
  visits = $(column + '.visit')
  direct_total = 0
  $(visits).each (index, visit) =>
    if $(visit).is(':hidden') == false && $(visit).data('cents')
      direct_total += $(visit).data('cents') / 100.00

  indirect_rate = parseFloat($("#indirect_rate").val()) / 100.0
  indirect_total = direct_total * indirect_rate
  max_total = direct_total + indirect_total

  direct_total_display = '$' + (direct_total).toFixed(2)
  indirect_total_display = '$' + indirect_total.toFixed(2)
  max_total_display = '$' + max_total.toFixed(2)

  $(column + '.max_direct_per_patient').html(direct_total_display)
  $(column + '.max_indirect_per_patient').html(indirect_total_display)
  $(column + '.max_total_per_patient').html(max_total_display)

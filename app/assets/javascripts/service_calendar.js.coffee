#= require navigation

$(document).ready ->
  $('#service_calendar').tabs()
  
  $('.line_item_visit_template').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&checked=#{$(this).is(':checked')}"
    .complete ->
      $('.service_calendar_spinner').hide()


  $('.line_item_visit_quantity').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&qty=#{$(this).val()}"
    .complete ->
      $('.service_calendar_spinner').hide()
  
  $('.line_item_visit_billing').live 'change', ->
    $('.service_calendar_spinner').show()
    $.ajax
      type: 'PUT'
      url: $(this).attr('update') + "&qty=#{$(this).val()}"
    .complete ->
      $('.service_calendar_spinner').hide()


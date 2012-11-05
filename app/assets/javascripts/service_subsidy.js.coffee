#= require navigation

$(document).ready ->

  $('.pi-contribution').keypress (event) ->
    if event.keyCode is 13
      event.preventDefault()
      $(this).change()

  $('.pi-contribution').live 'change', ->
    id = $(this).attr('data-id')
    direct_cost = $('.estimated_cost_' + id).data('cost') / 100
    contribution = $(this).val()
    if contribution > direct_cost
      contribution = direct_cost
      $(this).val(direct_cost)

    rf = calculate_requested_funding(direct_cost, contribution)
    rf_display = '$' + rf.toFixed(2)
    $('.requested_funding_' + id).text(rf_display)

    percent = calculate_subsidy_percent(direct_cost, contribution)
    percent_display = if percent != "" then percent.toFixed(1) + '%' else '0%'
    $('.subsidy_percent_' + id).text(percent_display)

  calculate_requested_funding = (direct_cost, contribution) ->
    rf = 0
    if contribution > 0
      rf = (direct_cost - contribution)
    rf

  calculate_subsidy_percent = (direct_cost, contribution) ->
    percent = 0
    if contribution > 0
      funded_amount = direct_cost - contribution
      percent = (funded_amount / direct_cost) * 100
    percent

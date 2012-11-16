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

  $('#navigation_form').submit ->
    message = ""
    pass = true
    # check stuff
    $('.pi-contribution').each (index, elem) ->
      pi = $(this).val()

      if pi == ''
        pass = true
      else
        id = $(this).attr('data-id')
        direct_cost = $('.estimated_cost_' + id).data('cost') / 100
        max_dollar = $(this).attr('data-max_dollar')
        max_percent = $(this).attr('data-max_percent')
        core = $('.core_' + id).text()

        if max_dollar > 0.0
          if calculate_requested_funding(direct_cost, pi) > max_dollar
            pass = false
            message = 'Subsidy amount for ' + core + ' cannot exceed maximum dollar amount of $' + max_dollar
            return
        if max_percent > 0.0
          if calculate_subsidy_percent(direct_cost, pi) > max_percent
            pass = false
            message = 'Subsidy amount for ' + core + ' cannot exceed maximum percentage of ' + max_percent + '%'
            return

    if pass == false
      $("#submit_error .message").html(message)
      $("#submit_error").dialog
        modal: true
        buttons:
          Ok: ->
            $(this).dialog('close')
    return pass

  calculate_requested_funding = (direct_cost, contribution) ->
    rf = 0
    if contribution >= 0 and contribution != ""
      rf = (direct_cost - contribution)
    rf

  calculate_subsidy_percent = (direct_cost, contribution) ->
    percent = 0
    if contribution >= 0 and contribution != ""
      funded_amount = direct_cost - contribution
      percent = (funded_amount / direct_cost) * 100
    percent

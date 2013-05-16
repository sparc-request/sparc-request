#= require navigation

$(document).ready ->

  # Any time that Enter is pressed, emit a change event
  $('.pi-contribution').keypress (event) ->
    if event.keyCode is 13
      event.preventDefault()
      $(this).change()

  # Recalculate requested funding and subsidy percentage whenever pi
  # contribution changes
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
    percent_display = if percent != "" then percent.toFixed(2) + '%' else '0%'
    $('.subsidy_percent_' + id).text(percent_display)

  # Validate the form before we submit it
  $('#navigation_form').submit ->
    message = ""
    pass = true

    # Validate each subsidy.  If one of them fails, break out of the
    # loop early.
    $('.pi-contribution').each (index, elem) ->
      try
        [ pass, message ] = validate_pi_contribution($(this))
        if (!pass)
          return false
      catch error

    # If any subsidy failed to pass, emit an error message
    if pass == false
      $("#submit_error .message").html(message)
      $("#submit_error").dialog
        modal: true
        buttons:
          Ok: ->
            $(this).dialog('close')

    return pass

  # Validate the PI contribution for a subsidy.  Returns a 2-tuple
  # containing:
  #
  #    pass - true if validation passes, false otherwise
  #    message - a string containing the error message if validation
  #    fails
  #
  validate_pi_contribution = (pi) ->
    pass = true
    message = ''

    # if the pi contribution field is empty, then ignore it altogether
    if pi.val() == ''
      pass = true

    else
      id = pi.attr('data-id')
      direct_cost = $('.estimated_cost_' + id).data('cost') / 100
      max_dollar = pi.attr('data-max_dollar')
      max_percent = pi.attr('data-max_percent')
      core = $('.core_' + id).text()

      # Ensure that the requested funding is less than the maximum
      # dollar amount for the subsidy
      if max_dollar > 0.0 and calculate_requested_funding(direct_cost, pi.val()) > max_dollar
        pass = false
        message = 'Subsidy amount for ' + core + ' cannot exceed maximum dollar amount of $' + max_dollar

      # Ensure that the percent allocated to the subsidy is less than
      # the maximum percentage for that subsidy
      else if max_percent > 0.0 and calculate_subsidy_percent(direct_cost, pi.val()) > max_percent
        pass = false
        message = 'Subsidy amount for ' + core + ' cannot exceed maximum percentage of ' + max_percent + '%'

    return [ pass, message ]

  # Given a direct cost and a percent contribution, calculate the amount
  # of requested funding
  calculate_requested_funding = (direct_cost, contribution) ->
    rf = 0
    if contribution >= 0 and contribution != ""
      rf = (direct_cost - contribution)
    return rf

  # Given a direct cost and a percent contribution, calculate the
  # percent allocated for the subsidy
  calculate_subsidy_percent = (direct_cost, contribution) ->
    percent = 0
    if contribution >= 0 and contribution != ""
      funded_amount = direct_cost - contribution
      percent = (funded_amount / direct_cost) * 100
    return percent


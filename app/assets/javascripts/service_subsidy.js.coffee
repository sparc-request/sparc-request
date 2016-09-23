# Copyright © 2011-2016 MUSC Foundation for Research Development
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

#= require navigation

(exports ? this).formatMoney = (n, t=',', d='.', c='$') ->
  s = if n < 0 then "-#{c}" else c
  i = Math.abs(n).toFixed(2)
  j = (if (i.length > 3 && i > 0) then i.length % 3 else 0)
  s += i.substr(0, j) + t if j
  return s + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t)

$(document).ready ->

#****************** SERVICE SUBSIDY BEGIN ***************************#
  $(document).on 'click', '.add_subsidy_button', ->
    data =
      'subsidy' :
        'sub_service_request_id': $(this).data('sub-service-request-id'),
    $.ajax
      type: 'POST'
      url:  "/subsidies"
      data: data

  $(document).on 'click', '.delete_subsidy_button', ->
    subsidy_id = $(this).data('subsidy-id')
    $.ajax
      type: 'DELETE'
      url: "/subsidies/#{subsidy_id}"

#****************** SERVICE SUBSIDY END ***************************#

#****************** SUBSIDY FORM BEGIN ***************************#
  $(document).on 'change', '#pi_contribution', ->
    # When user changes PI Contribution, the Percent Subsidy and Subsidy Cost fields are recalculated & displayed
    max_percent = $(this).data('max-percentage')
    max_dollar_cap = $(this).data('max-dollar-cap')
    subsidy_id = $(this).data('subsidy-id')
    current_percent_subsidy = (parseFloat($('#percent_subsidy').val()) / 100.0)
    pi_contribution = parseFloat $(this).val().replace('$', '').replace(',', '')
    total_request_cost = parseFloat($(".request_cost[data-subsidy-id='#{subsidy_id}']").data("cost")) / 100.0
    percent_subsidy = (recalculate_percent_subsidy(total_request_cost, pi_contribution) * 100).toFixed(2) / 100.0
    original_pi_contribution = recalculate_pi_contribution(total_request_cost, current_percent_subsidy)

    if (parseFloat(percent_subsidy) * 100) > parseFloat(max_percent)
      message = "The Percent Subsidy cannot be greater than the max percent of #{max_percent}."
      current_cost = recalculate_current_cost(total_request_cost, current_percent_subsidy)
      display_error_and_reset(subsidy_id, current_percent_subsidy, original_pi_contribution, current_cost, max_percent, message)
    else if recalculate_current_cost(total_request_cost, (percent_subsidy)) > max_dollar_cap
      message = "The Subsidy Cost cannot be greater than the max dollar cap of #{max_dollar_cap}."
      current_cost = recalculate_current_cost(total_request_cost, current_percent_subsidy)
      display_error_and_reset(subsidy_id, current_percent_subsidy, original_pi_contribution, current_cost, max_percent, message)
    else

      if isNaN(pi_contribution)
        pi_contribution = 0
      if pi_contribution > total_request_cost
        pi_contribution = total_request_cost
      else if pi_contribution < 0
        pi_contribution = 0

      data = 'subsidy' :
        'pi_contribution' : pi_contribution
        'percent_subsidy' : percent_subsidy
      $.ajax
        type: 'PUT'
        url:  "/subsidies/#{subsidy_id}"
        data: data
        success: (data, textStatus, jqXHR) ->
          percent_subsidy = recalculate_percent_subsidy(total_request_cost, pi_contribution)
          current_cost = recalculate_current_cost(total_request_cost, percent_subsidy)
          redisplay_form_values(subsidy_id, percent_subsidy, pi_contribution, current_cost)
        error: (jqXHR, textStatus, errorThrown) ->
          $(this).val($(this).defaultValue)

  $(document).on 'change', '#percent_subsidy', ->
    # When user changes Percent Subsidy, the PI Contribution and Subsidy Cost fields are recalculated & displayed
    max_percent = $(this).data('max-percentage')
    max_dollar_cap = $(this).data('max-dollar-cap')
    subsidy_id = $(this).data('subsidy-id')
    percent_subsidy = parseFloat($(this).val()) / 100.0
    original_pi_contribution = parseFloat($('#pi_contribution').val().replace('$', '').replace(',', ''))
    total_request_cost = parseFloat($(".request_cost[data-subsidy-id='#{subsidy_id}']").data("cost")) / 100.0
    pi_contribution = recalculate_pi_contribution(total_request_cost, percent_subsidy)
    original_subsidy = recalculate_percent_subsidy(total_request_cost, original_pi_contribution)

    if (parseFloat(percent_subsidy * 100)) > parseFloat(max_percent)
      message = "The Percent Subsidy cannot be greater than the max percent of #{max_percent}."
      current_cost = recalculate_current_cost(total_request_cost, original_subsidy)
      display_error_and_reset(subsidy_id, original_subsidy, original_pi_contribution, current_cost, max_percent, message)
    else if recalculate_current_cost(total_request_cost, percent_subsidy) > max_dollar_cap
      message = "The Subsidy Cost cannot be greater than the max dollar cap of #{max_dollar_cap}."
      current_cost = recalculate_current_cost(total_request_cost, original_subsidy)
      display_error_and_reset(subsidy_id, original_subsidy, original_pi_contribution, current_cost, max_percent, message)
    else

      if isNaN(percent_subsidy)
        percent_subsidy = 0
      if percent_subsidy > 1
        percent_subsidy = 1.0
      else if percent_subsidy < 0
        percent_subsidy = 0

      data = 'subsidy' :
        'pi_contribution' : pi_contribution,
        'percent_subsidy' : percent_subsidy
      $.ajax
        type: 'PUT'
        url:  "/subsidies/#{subsidy_id}"
        data: data
        success: (data, textStatus, jqXHR) ->
          current_cost = recalculate_current_cost(total_request_cost, percent_subsidy)
          redisplay_form_values(subsidy_id, percent_subsidy, pi_contribution, current_cost)
        error: (jqXHR, textStatus, errorThrown) ->
          $(this).val($(this).defaultValue)

  recalculate_pi_contribution = (total_request_cost, percent_subsidy) ->
    contribution = total_request_cost - (total_request_cost * percent_subsidy)
    return if isNaN(contribution) then total_request_cost else contribution
  recalculate_percent_subsidy = (total_request_cost, pi_contribution) ->
    percentage = (total_request_cost - pi_contribution) / total_request_cost
    return if isNaN(percentage) then 1 else percentage
  recalculate_current_cost = (total_request_cost, percent_subsidy) ->
    current = total_request_cost * percent_subsidy
    return if isNaN(current) then 0 else current

  redisplay_form_values = (subsidy_id, percent_subsidy, pi_contribution, current_cost) ->
    $("#percent_subsidy[data-subsidy-id='#{subsidy_id}']").val( (percent_subsidy*100.0).toFixed(2) )
    $("#pi_contribution[data-subsidy-id='#{subsidy_id}']").val( format_currency(pi_contribution) )
    $(".subsidy_cost[data-subsidy-id='#{subsidy_id}']").text( format_currency(current_cost) )

  format_currency = (total) ->
    ('$' + parseFloat(total, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString())

  display_error_and_reset = (subsidy_id, percent, pi_contribution, current_cost, max_percent, message) ->
    $("#submit_error .message").html(message)
    $("#submit_error").dialog
      modal: true
      buttons:
        Ok: ->
          $(this).dialog('close')
    redisplay_form_values(subsidy_id, percent, pi_contribution, current_cost)


  $("#pi_contribution").val( format_currency($("#pi_contribution").val()) )

  validate_subsidy = () ->

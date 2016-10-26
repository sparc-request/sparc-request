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

$(document).ready ->

#****************** SUBSIDY INFORMATION BEGIN ***************************#
  $(document).on 'click', '#add_subsidy_button', ->
    data =
      'sub_service_request_id': $(this).data('sub-service-request-id'),
      'admin'                 : $(this).data('admin')
    $.ajax
      type: 'GET'
      url:  "/dashboard/subsidies/new"
      data: data

  $(document).on 'click', '#edit_subsidy_button', ->
    id = $(this).data('subsidy-id')
    data = 'admin' : $(this).data('admin')
    $.ajax
      type: 'GET'
      url:  "/dashboard/subsidies/#{id}/edit"
      data: data

  $(document).on 'click', '.delete_subsidy_button', ->
    subsidy_id = $(this).data('subsidy-id')

    if confirm("Are you sure that you would like to delete this subsidy?")
      $.ajax
        type: 'DELETE'
        url: "/dashboard/subsidies/#{subsidy_id}"

  $(document).on 'click', '#approve_subsidy_button', ->
    id = $(this).data('subsidy-id')
    $.ajax
      type: 'PATCH'
      url:  "/dashboard/subsidies/#{id}/approve"

#****************** SUBSIDY INFORMATION END ***************************#

#****************** SUBSIDY FORM BEGIN ***************************#
  $(document).on 'change', '#pending_subsidy_pi_contribution', ->
    # When user changes PI Contribution, the Percent Subsidy and Subsidy Cost fields are recalculated & displayed
    pi_contribution = parseFloat $(this).val()
    total_request_cost = parseFloat($("#subsidy_form_table_request_cost").data("cost")) / 100.0
    if isNaN(pi_contribution)
      pi_contribution = 0
    if pi_contribution > total_request_cost
      pi_contribution = total_request_cost
    else if pi_contribution < 0
      pi_contribution = 0
    percent_subsidy = recalculate_percent_subsidy(total_request_cost, pi_contribution)
    current_cost = recalculate_current_cost(total_request_cost, percent_subsidy)
    redisplay_form_values(percent_subsidy, pi_contribution, current_cost)

  $(document).on 'change', '#pending_subsidy_percent_subsidy', ->
    # When user changes Percent Subsidy, the PI Contribution and Subsidy Cost fields are recalculated & displayed
    percent_subsidy = parseFloat($(this).val()) / 100.0
    total_request_cost = parseFloat($("#subsidy_form_table_request_cost").data("cost")) / 100.0
    if isNaN(percent_subsidy)
      percent_subsidy = 0
    if percent_subsidy > 1
      percent_subsidy = 1.0
    else if percent_subsidy < 0
      percent_subsidy = 0
    pi_contribution = recalculate_pi_contribution(total_request_cost, percent_subsidy)
    current_cost = recalculate_current_cost(total_request_cost, percent_subsidy)
    redisplay_form_values(percent_subsidy, pi_contribution, current_cost)

  recalculate_current_cost = (total_request_cost, percent_subsidy) ->
    current = total_request_cost * percent_subsidy
    return if isNaN(current) then 1 else current
  recalculate_pi_contribution = (total_request_cost, percent_subsidy) ->
    contribution = total_request_cost - (total_request_cost * percent_subsidy)
    return if isNaN(contribution) then total_request_cost else contribution
  recalculate_percent_subsidy = (total_request_cost, pi_contribution) ->
    percentage = (total_request_cost - pi_contribution) / total_request_cost
    return if isNaN(percentage) then 0 else percentage

  redisplay_form_values = (percent_subsidy, pi_contribution, current_cost) ->
    $('#pending_subsidy_percent_subsidy').val( (percent_subsidy*100.0).toFixed(2) )
    $("#pending_subsidy_pi_contribution").val( format_currency(pi_contribution) )
    $("#subsidy_form_table_subsidy_cost").text( format_currency(current_cost) )

  format_currency = (total) ->
    (parseFloat(total, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString())



#****************** SUBSIDY FORM END ***************************#

  $(document).on 'click', '#details-tab', ->
    $("#pending_subsidy").load(location.href + " #pending_subsidy")


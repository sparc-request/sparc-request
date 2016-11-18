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

$(document).ready ->
  $(document).on 'click', '.page-change-arrow', ->
    unless $(this).attr('disabled')
      $.ajax
        type: 'GET'
        url: $(this).data('url')

  $(document).on 'click', '.service-calendar-row', ->
    if confirm(I18n['calendars']['confirm_row_select'])
      $.ajax
        type: 'post'
        url: $(this).data('url')

  $(document).on 'click', '.service-calendar-column', ->
    if confirm(I18n['calendars']['confirm_column_select'])
      $.ajax
        type: 'post'
        url: $(this).data('url')

  $(document).on 'change', '.visit-group-select .selectpicker', ->
    page = $(this).find('option:selected').attr('page')

    $.ajax
      type: 'GET'
      url: $(this).data('url')
      data:
        page: page

  $(document).on 'click', '.move-visit-button', ->
    arm_id = $(this).data('arm-id')
    $.ajax
      type: 'GET'
      url: '/service_calendars/show_move_visits'
      data: arm_id: arm_id
    return false

  $(document).on 'change', '.visit-quantity', ->
    checked = $(this).is(':checked')
    obj     = $(this)

    $.ajax
      type: 'PUT'
      data: 
        checked:  checked
        visit_id: $(this).data('visit-id')
        portal: $(this).data('portal')
        sub_service_request_id: $(this).data('ssrid')
      url: $(this).attr('update')

(exports ? this).changing_tabs_calculating_rates = ->
  arm_ids = []
  $('.calendar-container').each (index, arm) ->
    arm_ids.push( $(arm).data('arm-id') )

  i = 0
  while i < arm_ids.length
    calculate_max_rates(arm_ids[i])
    i++

calculate_max_rates = (arm_id) ->
  for num in [1..$(".arm-calendar-container-#{arm_id} .visit-group-box:visible").length]
    column = '.visit-' + num
    visits = $(".arm-calendar-container-#{arm_id}:visible #{column}.visit")

    direct_total = 0
    $(visits).each (index, visit) ->
      direct_total += Math.floor($(visit).data('cents')) / 100.0

    indirect_rate = parseFloat($("#indirect_rate").val()) / 100.0
    indirect_total = 0
    max_total = direct_total + indirect_total

    direct_total_display = '$' + (direct_total).toFixed(2)
    indirect_total_display = '$' + (Math.floor(indirect_total * 100) / 100).toFixed(2)
    max_total_display = '$' + (Math.floor(max_total * 100) / 100).toFixed(2)

    $(".arm-calendar-container-#{arm_id}:visible #{column}.max-direct-per-patient").html(direct_total_display)
    $(".arm-calendar-container-#{arm_id}:visible #{column}.max-indirect-per-patient").html(indirect_total_display)
    $(".arm-calendar-container-#{arm_id}:visible #{column}.max-total-per-patient").html(max_total_display)

(exports ? this).setup_xeditable_fields = () ->
  # Override x-editable defaults
  $.fn.editable.defaults.send = 'always'
  $.fn.editable.defaults.ajaxOptions =
    type: "PUT",
    dataType: "json"
  $.fn.editable.defaults.error = (response, newValue) ->
    error_msgs = []
    $.each JSON.parse(response.responseText), (attr, errors) ->
      for err in errors
        error_msgs.push(humanize_string(attr)+err)
    return error_msgs.join("\n")

  $('.window-before').editable
    params: (params) ->
      data = 'visit_group': { 'window_before': params.value }
      return data

  $('.day').editable
    params: (params) ->
      data = 'visit_group': { 'day': params.value }
      return data

  $('.window-after').editable
    params: (params) ->
      data = 'visit_group': { 'window_after': params.value }
      return data

  $('.visit-group-name').editable
    params: (params) ->
      data = 'visit_group': { 'name': params.value }
      return data

  $('.edit-your-cost').editable
    display: (value) ->
      # display field as currency, edit as quantity
      $(this).text("$" + parseFloat(value).toFixed(2))
    params: (params) ->
      data = 'line_item': { 'displayed_cost': params.value }
      return data
    success: ->

  $('.edit-subject-count').editable
    params: (params) ->
      data = 'line_items_visit': { 'subject_count': params.value }
      return data

  $('.edit-research-billing-qty').editable
    params: (params) ->
      data = 'visit': { 'research_billing_qty': params.value }
      return data

  $('.edit-insurance-billing-qty').editable
    params: (params) ->
      data = 'visit': { 'insurance_billing_qty': params.value }
      return data

  $('.edit-effort-billing-qty').editable
    params: (params) ->
      data = 'visit': { 'effort_billing_qty': params.value }
      return data

  $('.edit-qty').editable
    params: (params) ->
      data = 'line_item': { 'quantity': params.value }
      return data

  $('.edit-units-per-qty').editable
    params: (params) ->
      data = 'line_item': { 'units_per_quantity': params.value }
      return data

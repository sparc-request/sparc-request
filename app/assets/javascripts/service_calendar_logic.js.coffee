# Copyright © 2011 MUSC Foundation for Research Development
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
  $('.selectpicker').selectpicker()
  $('[data-toggle="tooltip"]').tooltip()
  changing_tabs_calculating_rates()

  # Override x-editable defaults
  $.fn.editable.defaults.send = 'always'
  $.fn.editable.defaults.ajaxOptions =
    type: "PUT",
    dataType: "json"
  $.fn.editable.defaults.error = (response, newValue) ->
    error_msgs = []
    $.each JSON.parse(response.responseText), (key, value) ->
      error_msgs.push(humanize_string(key)+' '+value)
    return error_msgs.join("<br>")

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

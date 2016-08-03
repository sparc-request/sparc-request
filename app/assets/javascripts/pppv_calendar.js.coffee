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

# This file deals with SPARC Proper Service Calendar Only Logic
# Other shared logic can be found in javascripts/dashboard/pppv_calendar.js

$(document).ready ->
  $('.selectpicker').selectpicker()

  # Override x-editable defaults
  $.fn.editable.defaults.send = 'always'
  $.fn.editable.defaults.ajaxOptions =
    type: "PUT",
    dataType: "json"
  $.fn.editable.defaults.error = (response, newValue) ->
    error_msgs = []
    $.each JSON.parse(response.responseText), (key, value) ->
      error_msgs.push(key+' '+value)
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

  $('.edit-subject-count').editable
    validate: (val) ->
      n = ~~Number(val)
      max_subject_count = $(this).data('max-subject-count')
      if String(n) != val || n < 0
        return "quantity must be a nonnegative number"
      else if n > max_subject_count
        return "The N cannot exceed the maximum subject count of the arm (" + max_subject_count + ")"

  $('.edit-your-cost').editable
    title: 'Edit your cost'
    display: (value) ->
      # display field as currency, edit as quantity
      $(this).text("$" + parseFloat(value).toFixed(2))
    validate: (value) ->
      n = +value;
      if isNaN(n) || n < 0
        return "cost must be a nonnegative number"
    params: (params) ->
      data = 'line_item': {'displayed_cost': params.value}
      return data

  validate_billing_qty = (val) ->
    n = ~~Number(val)
    if String(n) != val || n < 0
      return "quantity must be a positive number"

  $('.edit-research-billing-qty').editable
    title: 'Edit research billing quantity'
    validate: validate_billing_qty

  $('.edit-insurance-billing-qty').editable
    title: 'Edit insurance billing quantity'
    validate: validate_billing_qty

  $('.edit-effort-billing-qty').editable
    title: 'Edit effort billing quantity'
    validate: validate_billing_qty

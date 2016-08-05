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

#= require navigation

$(document).ready ->
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

(exports ? this).changing_tabs_calculating_rates = ->
  arm_ids = []
  $('.calendar-container').each (index, arm) ->
    arm_ids.push( $(arm).data('arm-id') )

  i = 0
  while i < arm_ids.length
    calculate_max_rates(arm_ids[i])
    i++

(exports ? this).calculate_max_rates = (arm_id) ->
  for num in [1..$('.visit-group-box:visible').length]
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

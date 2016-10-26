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
  # $('.selectpicker').selectpicker()

  # $(".visit_name").live 'mouseover', ->
  $(".visit_name").qtip
    overwrite: false
    content: I18n["service_calendar_toasts"]["visit_name"]
    position:
      corner:
        target: 'bottomLeft'
    show:
      ready: false

  # $('.visit_day').live 'mouseover', ->
  $('.visit_day').qtip
    overwrite: false
    content: I18n["service_calendar_toasts"]["visit_day"]
    position:
      corner:
        target: 'topLeft'
        tooltip: 'bottomLeft'
    show:
      ready: false

  $('.visit_window_before').qtip
    overwrite: false
    content: I18n["service_calendar_toasts"]["visit_window_before"]
    position:
      corner:
        target: 'topLeft'
        tooltip: 'bottomLeft'
    show:
      ready: false

  $('.visit_window_after').qtip
    overwrite: false
    content: I18n["service_calendar_toasts"]["visit_window_after"]
    position:
      corner:
        target: 'topLeft'
        tooltip: 'bottomLeft'
    show:
      ready: false

  # $('.billing_type_list').live 'mouseover', ->
  $('.billing_type_list').qtip
    overwrite: false
    content: 'R = Research<br />T = Third Party (Patient Insurance)<br />% = % Effort'
    position:
      corner:
        target: 'topMiddle'
        tooltip: 'bottomLeft'
    show:
      ready: false
    style:
      tip: true
      border:
        width: 0
        radius: 4
      name: 'light'
      width: 260

  changing_tabs_calculating_rates = ->
    arm_ids = []
    $('.arm_calendar_container').each (index, arm) ->
      if $(arm).is(':hidden') == false then arm_ids.push $(arm).data('arm_id')

    i = 0
    while i < arm_ids.length
      calculate_max_rates(arm_ids[i])
      i++

  if $('.line_item_visit_template').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_billing').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_quantity').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_pricing').is(':visible')
    changing_tabs_calculating_rates()

  $(document).on 'change', '.visit_group_select .selectpicker', ->
    page = $(this).find('option:selected').attr('page')

    $.ajax
      type: 'GET'
      url: $(this).data('url')
      data:
        page: page

# Copyright © 2011-2019 MUSC Foundation for Research Development
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
  ###################
  # Protocols Table #
  ###################

  $('#protocolsList .export button').addClass('no-caret').siblings('.dropdown-menu').addClass('d-none')

  $(document).on 'click', '#protocolsList .export button', ->
    url = new URL($('#protocolsTable').data('url'), window.location.origin)
    url.pathname = url.pathname.replace('json', 'csv')
    window.location = url

  ####################
  # Protocol Filters #
  ####################

  $(document).on 'click', '#saveProtocolFilters', ->
    data = {}

    $.each $('form#protocolFiltersForm').serializeArray(), (i, field) ->
      data[field.name] = field.value

    if data["filterrific[with_status][]"].length
      data["filterrific[with_status][]"] = $("#filterrific_with_status").val()

    if data["filterrific[with_organization][]"] && data["filterrific[with_organization][]"].length
      data["filterrific[with_organization][]"] = $("#filterrific_with_organization").val()

    if data["filterrific[with_owner][]"] && data["filterrific[with_owner][]"].length
      data["filterrific[with_owner][]"] = $("#filterrific_with_owner").val()

    $.ajax
      type: 'GET'
      url:  "/dashboard/protocol_filters/new"
      data: data

  #################
  # Protocol Show #
  #################

  if window.location.pathname.startsWith('/dashboard')
    $(document).on 'keyup', '.milestone-field.datetimepicker input', (event) ->
      key = event.keyCode || event.charCode
      if !$(this).val() && [8, 46].includes(key) # Backspace or Delete keys
        data = $(this).serialize()

        $.ajax
          method: 'put'
          dataType: 'script'
          url: "/dashboard/protocols/#{getProtocolId()}"
          data: data

    $(document).on 'change.datetimepicker', '.milestone-field.datetimepicker', ->
      data = $(this).find('input').serialize()

      $.ajax
        method: 'put'
        dataType: 'script'
        url: "/dashboard/protocols/#{getProtocolId()}"
        data: data

    milestoneTimer = null
    $(document).on('keydown', '.milestone-field:not(.datetimepicker) input', ->
      clearTimeout(milestoneTimer)
    ).on('keyup', '.milestone-field:not(.datetimepicker) input', ->
      clearTimeout(milestoneTimer)

      data = $(this).serialize()

      milestoneTimer = setTimeout( (->
        $.ajax
          method: 'put'
          dataType: 'script'
          url: "/dashboard/protocols/#{getProtocolId()}"
          data: data
      ), 500)
    )

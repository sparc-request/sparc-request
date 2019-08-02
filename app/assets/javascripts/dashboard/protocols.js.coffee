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

  $('#protocolsList .export button').removeClass('dropdown-toggle').attr('data-toggle', 'tooltip').data('toggle', 'tooltip').attr('title', I18n.t('dashboard.protocols.table.tooltips.export'))

  $(document).on 'click', '#protocolsList .export button', ->
    url = new URL($('#protocolsTable').data('url'), window.location.origin)
    url.pathname = url.pathname.replace('json', 'csv')
    window.location = url

  $(document).on 'click', '#protocolsTable tbody tr', (event) ->
    if event.target.tagName != 'A'
      window.location = $(this).find('.protocol-link').attr('href')

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

  # Milestone Updates
  if window.location.pathname.startsWith('/dashboard')
    $('.milestone-field.datetimepicker').on 'hide.datetimepicker', ->
      $.ajax
        method: 'PUT'
        dataType: 'script'
        url: "/dashboard/protocols/#{getProtocolId()}"
        data: $(this).children('input').serialize()

    $('.milestone-field:not(.datetimepicker').on 'change', ->
      $.ajax
        method: 'PUT'
        dataType: 'script'
        url: "/dashboard/protocols/#{getProtocolId()}"
        data: $(this).children('input').serialize()

  Sparc = {}
  Sparc.protocol =
    ready: ->
      # Protocol Show Begin
      $(document).on 'click', '#add-services-button', ->
        if $(this).data('permission')
          protocol_id         = $(this).data('protocol-id')
          window.location     = "/?protocol_id=#{protocol_id}&from_portal=true"

      $(document).on 'change', '.complete-forms', ->
        if $(this).val()
          $option = $('option:selected', this)
          $this   = $(this)

          $.ajax
            method: 'GET'
            url: "/surveyor/responses/new.js"
            data:
              type:             $option.data('type')
              survey_id:        $option.data('survey-id')
              respondable_id:   $option.data('respondable-id')
              respondable_type: $option.data('respondable-type')
            success: ->
              $this.selectpicker('val', '')

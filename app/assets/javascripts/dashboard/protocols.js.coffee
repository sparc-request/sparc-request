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

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  Sparc.protocol =
    ready: ->
      $(document).on 'click', '.calendar-lock', ->
        protocol_id = $(this).data('protocol-id')
        locked = $(this).data('locked')
        data =
        'protocol_id'       : protocol_id,
        'locked'            : locked
        $.ajax
          type: 'PUT'
          url: "/dashboard/protocols/#{protocol_id}"
          data: data

      #  Protocol Index Begin
      $(document).on 'click', '.protocols_index_row > .id, .protocols_index_row > .title, .protocols_index_row > .pis', ->
        #if you click on the row, it opens the protocol show
        protocol_id = $(this).parent().data('protocol-id')
        window.location = "/dashboard/protocols/#{protocol_id}"

      $(document).on 'click', '.requests_display_link', ->
        # Opens the requests modal
        protocol_id = $(this).parents("tr").data('protocol-id')
        $.ajax
          type: 'get'
          url: "/dashboard/protocols/#{protocol_id}/display_requests"
          success: (data) ->
            $('#modal_place').html(data.modal)
            $('#modal_place').modal 'show'
            $('.service-requests-table').bootstrapTable()
            reset_service_requests_handlers()

      $(document).on 'click', '.protocol-archive-button', ->
        protocol_id = $(this).data('protocol-id')
        $.ajax
          type: 'PATCH'
          url:  "/dashboard/protocols/#{protocol_id}/archive.js"

      $(document).on 'submit', '#filterrific-no-ajax-auto-submit', ->
        $('#filterrific_sorted_by').val("#{$('.protocol-sort').data('sort-name')} #{$('.protocol-sort').data('sort-order')}")

      $(document).on 'click', '#save_filters_link', ->
        data = {} #Grab form values

        # REVIEW this is not fetching values from multiselects
        $.each $('form#filterrific-no-ajax-auto-submit').serializeArray(), (i, field) ->
          data[field.name] = field.value

        # manually enter those in
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
        return false

      $(document).on 'click', '#reset_filters_link, .saved_search_link', ->
        # This makes the reset filter and saved search links go through AJAX
        $.getScript @href
        false

      $(document).on 'click', '.pagination a', ->
        # This makes the pagination links go through AJAX, rather than link hrefs
        $('.pagination').html 'Page is loading...'
        $.getScript @href
        false
      # Protocol Index End

      # Protocol Show Begin
      $(document).on 'click', '.view-protocol-details-button', ->
        protocol_id = $(this).data('protocol-id')
        $.ajax
          method: 'get'
          url: "/protocols/#{protocol_id}.js?portal=true"

      $(document).on 'click', '.edit-protocol-information-button', ->
        if $(this).data('permission')
          protocol_id = $(this).data('protocol-id')
          window.location = "/dashboard/protocols/#{protocol_id}/edit"

      $(document).on 'click', '.view-full-calendar-button', ->
        protocol_id = $(this).data('protocolId')
        statuses_hidden = $(this).data('statusesHidden')
        $.ajax
          method: 'get'
          url: "/service_calendars/view_full_calendar.js"
          data:
            portal: 'true'
            protocol_id: protocol_id
            statuses_hidden: statuses_hidden

      $(document).on 'click', '.view-service-request', ->
        id = $(this).data('sub-service-request-id')
        show_view_ssr_back = $(this).data('show-view-ssr-back')
        $.ajax
          method: 'GET'
          url: "/dashboard/sub_service_requests/#{id}.js"
          data: show_view_ssr_back: show_view_ssr_back

      $(document).on 'click', '#add-services-button', ->
        if $(this).data('permission')
          protocol_id         = $(this).data('protocol-id')
          window.location     = "/?protocol_id=#{protocol_id}&from_portal=true"

      $(document).on 'click', '.view-ssr-back-button', ->
        protocol_id = $(this).data('protocol-id')
        $.ajax
          type: 'GET'
          url: "/dashboard/protocols/#{protocol_id}/display_requests"
          success: (data) ->
            $('#modal_place').html(data.modal)
            $('#modal_place').modal 'show'
            $('.service-requests-table').bootstrapTable()
            reset_service_requests_handlers()

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

      reset_service_requests_handlers()
      # Protocol Show End

      # Protocol Table Sorting
      $(document).on 'click', '.protocol-sort', ->
        sorted_by         = "#{$(this).data('sort-name')} #{$(this).data('sort-order')}"
        page              = $('#page').val() || 1

        data = {} #Grab form values

        # REVIEW this is not fetching values from multiselects
        $.each $('form#filterrific-no-ajax-auto-submit').serializeArray(), (i, field) ->
          data[field.name] = field.value

        data["page"] = page
        data["filterrific[sorted_by]"] = sorted_by

        # manually enter those in
        if data["filterrific[with_status][]"].length
          data["filterrific[with_status][]"] = $("#filterrific_with_status").val()

        if data["filterrific[with_organization][]"] && data["filterrific[with_organization][]"].length
          data["filterrific[with_organization][]"] = $("#filterrific_with_organization").val()

        if data["filterrific[with_owner][]"] && data["filterrific[with_owner][]"].length
          data["filterrific[with_owner][]"] = $("#filterrific_with_owner").val()

        $.ajax
          type: 'get'
          url: "/dashboard/protocols.js"
          data: data

(exports ? this).reset_service_requests_handlers = ->
  $('.view-consolidated').tooltip()
  $('.export-consolidated').tooltip()
  $('.coverage-analysis-report').tooltip()
  
  $('.service-requests-table').on 'all.bs.table', ->
    #Enable selectpickers
    $(this).find('.selectpicker').selectpicker()

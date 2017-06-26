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
  getSRId = ->
    $("input[name='service_request_id']").val()

  getSSRId = ->
    $("input[name='sub_service_request_id']").val()

  $(document).on 'click', '.custom-tab a', ->
    if $(this).is('#billing-strategy-tab')
      $('.billing-info ul').removeClass('hidden')
    else
      $('.billing-info ul').addClass('hidden')

  $(document).on 'click', '.page-change-arrow', ->
    scroll = $(this).parents('.scrolling-thead').length > 0
    unless $(this).attr('disabled')
      $.ajax
        type: 'GET'
        url: $(this).data('url')
        data:
          scroll: scroll

  $(document).on 'click', '.service-calendar-row', ->
    return false if $(this).attr('disabled')
    if confirm(I18n['calendars']['pppv']['editable_fields']['row_select']['confirm'])
      $.ajax
        type: 'post'
        url: $(this).data('url')

  $(document).on 'click', '.service-calendar-column', ->
    return false if $(this).attr('disabled')
    if confirm(I18n['calendars']['pppv']['editable_fields']['column_select']['confirm'])
      $.ajax
        type: 'post'
        url: $(this).data('url')

  $(document).on 'change', '.visit-group-select .selectpicker', ->
    scroll = $(this).parents('.scrolling-thead').length > 0
    page = $(this).find('option:selected').attr('page')

    $.ajax
      type: 'GET'
      url: $(this).data('url')
      data:
        page: page
        scroll: scroll

  $(document).on 'click', '.move-visit-button', ->
    $.ajax
      type: 'GET'
      url: '/service_calendars/show_move_visits'
      data:
        arm_id:                 $(this).data('arm-id')
        service_request_id:     getSRId()
        sub_service_request_id: getSSRId()
        tab:                    $(this).data('tab')
        pages:                  $(this).data('pages')
        page:                   $(this).data('page')
        review:                 $(this).data('review')
        portal:                 $(this).data('portal')
        admin:                  $(this).data('admin')
        merged:                 $(this).data('merged')
        consolidated:           $(this).data('consolidated')
        statuses_hidden:        $(this).data('statuses-hidden')
    return false

  $(document).on 'click', '.freeze-header-button', ->

    arm = $(this).data('arm-id')

    if arm == 'otf-calendar'
      arm_container = $(this).closest(".#{arm}")
    else
      arm_container = $(this).closest(".arm-calendar-container-#{arm}")

    if $(this).hasClass('freeze')
      arm_container.find('table').addClass('scrolling-table')
      arm_container.find('thead').addClass('scrolling-thead')
      arm_container.find('tbody').addClass('scrolling-div')
      $(this).find('.freeze-header').hide()
      $(this).find('.unfreeze-header').show()
      $(this).removeClass('freeze')
      $(this).addClass('unfreeze')
    else
      arm_container.find('table').removeClass('scrolling-table')
      arm_container.find('table').addClass('non-scrolling-table')
      arm_container.find('thead').removeClass('scrolling-thead')
      arm_container.find('tbody').removeClass('scrolling-div')
      $(this).find('.unfreeze-header').hide()
      $(this).find('.freeze-header').show()
      $(this).removeClass('unfreeze')
      $(this).addClass('freeze')

  $(document).on 'change', '.visit-quantity', ->
    $.ajax
      type: 'PUT'
      data:
        visit:
          quantity:               $(this).data('quantity')
          research_billing_qty:   $(this).data('research-billing-qty')
          insurance_billing_qty:  $(this).data('insurance-billing-qty')
          effort_billing_qty:     $(this).data('effort-billing-qty')
        service_request_id:       getSRId()
        sub_service_request_id:   getSSRId()
        admin:                    $(this).data('admin')
        tab:                      $(this).data('tab')
        page:                     $(this).data('page')
      url: "/visits/#{$(this).data('visit-id')}"

  $(document).on 'click', '.edit-billing-qty', ->
    $.ajax
      type: 'GET'
      data:
        service_request_id:     getSRId()
        sub_service_request_id: getSSRId()
        admin:                  $(this).data('admin')
        page:                   $(this).data('page')
      url: "/visits/#{$(this).data('visit-id')}/edit"

  $(document).on 'change', '#visit_group', ->
    arm_id = $('#arm_id').val()
    move_visit_button = $(".arm-calendar-container-#{arm_id}").find('.move-visit-button')
    $.ajax
      type: 'GET'
      url: '/service_calendars/show_move_visits'
      data:
        arm_id:                   arm_id
        visit_group_id:           $(this).val()
        service_request_id:       getSRId()
        sub_service_request_id:   getSSRId()
        tab:                      $(move_visit_button).data('tab')
        pages:                    $(move_visit_button).data('pages')
        page:                     $(move_visit_button).data('page')
        review:                   $(move_visit_button).data('review')
        portal:                   $(move_visit_button).data('portal')
        admin:                    $(move_visit_button).data('admin')
        merged:                   $(move_visit_button).data('merged')
        consolidated:             $(move_visit_button).data('consolidated')
        statuses_hidden:          $(move_visit_button).data('statuses-hidden')

  # NOTES LISTENERS BEGIN
  $(document).on 'click', 'button.btn-link.notes',  ->
    id = $(this).data('notable-id')
    type = $(this).data('notable-type')
    in_dashboard = $(this).data('in-dashboard')
    data = 
      note:
        notable_id: id
        notable_type: type
      in_dashboard: in_dashboard
    $.ajax
      type: 'GET'
      url: '/notes.js'
      data: data

  $(document).on 'click', 'button.note.new',  ->
    id = $(this).data('notable-id')
    type = $(this).data('notable-type')
    in_dashboard = $(this).data('in-dashboard')
    data = 
      note:
        notable_id: id
        notable_type: type
      in_dashboard : in_dashboard
    $.ajax
      type: 'GET'
      url: '/notes/new'
      data: data

  $(document).on 'click', 'button.notes.cancel',  ->
    id = $(this).data('notable-id')
    type = $(this).data('notable-type')
    data = note:
      notable_id: id
      notable_type: type
    $.ajax
      type: 'GET'
      url: '/notes'
      data: data
  # NOTES LISTENERS END

getSRId = ->
  $("input[name='service_request_id']").val()

(exports ? this).setup_xeditable_fields = (scroll) ->
  reload_calendar = (arm_id, scroll) ->
    # E.g. "billing-strategy-tab" -> "billing_strategy"
    tab = $('li.custom-tab.active a').last().attr('id')
    tab = tab.substring(0, tab.indexOf("tab") - 1).replace("-", "_")
    data = $('#service-calendars').data()
    data.scroll = scroll
    data.tab = tab
    data.arm_id = arm_id
    data.service_request_id = getSRId()
    data.sub_service_request_id = data.subServiceRequestId
    data.protocol_id = data.protocolId
    # Reload calendar
    $.get '/service_calendars/table.js', data

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
      {
        visit_group:
          window_before: params.value
        service_request_id: getSRId()
      }

  $('.day').editable
    params: (params) ->
      {
        visit_group:
          day: params.value
        service_request_id: getSRId()
      }
    emptytext: '(?)'

  $('.window-after').editable
    params: (params) ->
      {
        visit_group:
          window_after: params.value
        service_request_id: getSRId()
      }

  $('.visit-group-name').editable
    params: (params) ->
      {
        visit_group:
          name: params.value
        service_request_id: getSRId()
      }
    emptytext: '(?)'

  $('.edit-your-cost').editable
    display: (value) ->
      # display field as currency, edit as quantity
      $(this).text("$" + parseFloat(value).toFixed(2))
    params: (params) ->
      {
        line_item:
          displayed_cost: params.value
        service_request_id: getSRId()
      }
    success: (data) ->
      $('#sub_service_request_header').html(data['header'])
      $('.selectpicker').selectpicker()

  $('.edit-subject-count').editable
    params: (params) ->
      {
        line_items_visit:
          subject_count: params.value
        service_request_id: getSRId()
      }
    success: () ->
      scroll = $(this).parents('.scrolling-div').length > 0
      reload_calendar($(this).data('armId'), scroll)

  $('.edit-qty').editable
    params: (params) ->
      {
        line_item:
          quantity: params.value
        service_request_id: getSRId()
      }
    success: ->
      scroll = $(this).parents('.scrolling-div').length > 0
      reload_calendar($(this).data('armId'), scroll)

  $('.edit-units-per-qty').editable
    params: (params) ->
      {
        line_item:
          units_per_quantity: params.value
        service_request_id: getSRId()
      }
    success: ->
      scroll = $(this).parents('.scrolling-div').length > 0
      reload_calendar($(this).data('armId'), scroll)

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
  freezeHeader = (arm_container) ->
    $(arm_container).each ->
      $(this).find('table').addClass('scrolling-table')
      $(this).find('table').removeClass('non-scrolling-table')
      $(this).find('thead').addClass('scrolling-thead')
      $(this).find('tbody').addClass('scrolling-div')
      $(this).find('.freeze-header-button').find('.freeze-header').hide()
      $(this).find('.freeze-header-button').find('.unfreeze-header').show()
      $(this).find('.freeze-header-button').removeClass('freeze')
      $(this).find('.freeze-header-button').addClass('unfreeze')

  $(document).on 'click', '.custom-tab a', ->
    if $(this).is('#billing-strategy-tab')
      $('.billing-info ul').removeClass('hidden')
    else
      $('.billing-info ul').addClass('hidden')

    # Hold freeze header upon tab change
    $(document).ajaxComplete ->
      arm_ids_with_frozen_header = []
      frozen_headers = $('.unfreeze')
      frozen_headers.each (index, arm) ->
        if $(arm).data('arm-id') != undefined
          arm_ids_with_frozen_header.push( $(arm).data('arm-id') )

      $(jQuery.unique(arm_ids_with_frozen_header)).each (index, arm) ->
        if arm == 'otf-calendar'
          arm_container = $(".#{arm}")
        else
          arm_container = $(".arm-calendar-container-#{arm}")

        freezeHeader(arm_container)  

  $(document).on 'click', '.page-change-arrow', ->
    scroll = $(this).parents('.scrolling-thead').length > 0
    unless $(this).attr('disabled')
      $.ajax
        type: 'GET'
        url: $(this).data('url')
        data:
          scroll: scroll

  $(document).on 'click', '.edit-visit-group', ->
    $.ajax
      type: 'GET'
      url: "/visit_groups/#{$(this).data('id')}/edit.js"
      data:
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
      arm_container = $(".#{arm}")
    else
      arm_container = $(".arm-calendar-container-#{arm}")

    if $(this).hasClass('freeze')
      freezeHeader(arm_container)
    else
      $(arm_container).each ->
        $(this).find('table').removeClass('scrolling-table')
        $(this).find('table').addClass('non-scrolling-table')
        $(this).find('thead').removeClass('scrolling-thead')
        $(this).find('tbody').removeClass('scrolling-div')
        $(this).find('.freeze-header-button').find('.unfreeze-header').hide()
        $(this).find('.freeze-header-button').find('.freeze-header').show()
        $(this).find('.freeze-header-button').removeClass('unfreeze')
        $(this).find('.freeze-header-button').addClass('freeze')

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

(exports ? this).setup_xeditable_fields = (scroll) ->
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
        sub_service_request_id: getSSRId()
      }
    success: (data) ->
      arm_id = $(this).data('arm-id')
      
      # Replace Per Patient / Study Totals
      $(this).parent().siblings('.pppv-per-patient-line-item-total').replaceWith(data['total_per_patient'])
      $(this).parent().siblings('.pppv-per-study-line-item-total').replaceWith(data['total_per_study'])
      
      # Replace Totals
      $(".arm-#{arm_id}.maximum-total-direct-cost-per-patient").replaceWith(data['max_total_direct'])
      $(".arm-#{arm_id}.maximum-total-per-patient").replaceWith(data['max_total_per_patient'])
      $(".arm-#{arm_id}.total-per-patient-per-visit-cost-per-study").replaceWith(data['total_costs'])

      if data['ssr_header']
        # Replace Admin Dashboard SSR header
        $('#sub_service_request_header').html(data['ssr_header'])
        $('.selectpicker').selectpicker()

  $('.edit-qty').editable
    params: (params) ->
      {
        line_item:
          quantity: params.value
        service_request_id: getSRId()
        sub_service_request_id: getSSRId()
      }
    success: (data) ->
      # Replace Study Total
      $(this).parent().siblings('.total-per-study').replaceWith(data['total_per_study'])

      # Replace Totals
      $('.total-direct-one-time-fee-cost-per-study').replaceWith(data['max_total_direct'])
      $('.total-one-time-fee-cost-per-study').replaceWith(data['total_costs'])

  $('.edit-units-per-qty').editable
    params: (params) ->
      {
        line_item:
          units_per_quantity: params.value
        service_request_id: getSRId()
        sub_service_request_id: getSSRId()
      }
    success: (data) ->
      # Replace Study Total
      $(this).parent().siblings('.total-per-study').replaceWith(data['total_per_study'])

      # Replace Totals
      $('.total-direct-one-time-fee-cost-per-study').replaceWith(data['max_total_direct'])
      $('.total-one-time-fee-cost-per-study').replaceWith(data['total_costs'])

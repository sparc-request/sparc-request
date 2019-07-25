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

$(document).on 'turbolinks:load', ->
  
  #########################
  # Load Tab on Page Load #
  #########################

  if $('#serviceCalendar').length
    $.ajax
      method: 'get'
      dataType: 'script'
      url: $('#serviceCalendar .nav-tabs .nav-link.active').attr('href')
      success: ->
        $('#calendarLoading').removeClass('show active')

  ##########################
  # Visit Checkbox / Input #
  ##########################

  $(document).on 'click', 'td.visit:has(input), td.visit:has(a)', (event) ->
    if !(event.target.tagName in ['INPUT', 'A'])
      if $(this).hasClass('template-visit')
        $(this).find('input').click()
      else
        $.ajax
          method: 'GET'
          dataType: 'script'
          url: $(this).find('a').first().attr('href')

  $(document).on 'change', '.visit-quantity', ->
    $.ajax
      method: 'PUT'
      dataType: 'script'
      url: "/visits/#{$(this).data('visit-id')}"
      data:
        visit:
          quantity:               $(this).data('quantity')
          research_billing_qty:   $(this).data('research-billing-qty')
          insurance_billing_qty:  $(this).data('insurance-billing-qty')
          effort_billing_qty:     $(this).data('effort-billing-qty')
        srid:                     getSRId()
        ssrid:                    getSSRId()
        tab:                      $('#tab').val()
        page:                     $(this).parents('.arm-container').data('page')

  #####################
  # Change Visit Page #
  #####################

  $(document).on 'change', '.visit-group-select .selectpicker', ->
    scroll = $(this).parents('.scrolling-thead').length > 0
    page = $(this).find('option:selected').attr('page')
    display_all_services = $('.visit-group-select').hasClass('display_all_services')

    $.ajax
      method: 'GET'
      dataType: 'script'
      url: $(this).data('url')
      data:
        page: page
        scroll: scroll
        display_all_services: display_all_services

  ###########################
  # Update Move Visit Modal #
  ###########################

  $(document).on 'change', '#moveVisitForm #visit_group_id', ->
    $('#moveVisitForm #position').val('').selectpicker('refresh')
    $.ajax
      type: 'GET'
      url: '/service_calendars/show_move_visits'
      data: $('#moveVisitForm').serialize()

  $(document).on 'change', '#moveVisitForm #position', ->
    $.ajax
      type: 'GET'
      url: '/service_calendars/show_move_visits'
      data: $('#moveVisitForm').serialize()

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

  toggleServiceButtons = (clicked_button) ->
    $(clicked_button).addClass('active btn-success').removeClass('btn-custom-green')
    $(clicked_button).siblings().first().removeClass('active btn-success').addClass('btn-custom-green')

    # hide and show service toggle buttons based on current tab
    if $(this).is('#calendar_tab') || $(this).is('#calendar-tab')
      $('.toggle-services-btn-group').css('display', 'inline-block')
    else
      $('.toggle-services-btn-group').css('display', 'none')

    # reset toggle buttons
    toggleServiceButtons($('.toggle-services-btn-group').find('#chosen-services'))

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

  $(document).on 'click', '.services-toggle', (e) ->
    if !($(this).hasClass('active'))
      toggleServiceButtons($(this))
      href = this.hash
      pane = $(this)

      # helps keep track of which toggle button is active when changing visit dropdown
      if $(this).hasClass('all-services')
        $('.visit-group-select').addClass('display_all_services')
      else
        $('.visit-group-select').removeClass('display_all_services')

      $.ajax
        type: 'GET'
        url: $(this).attr("data-url")
        dataType: 'html'
        data:
          display_all_services: $(this).is('#all-services')
        success: (data) ->
          $(href).html data
          pane.tab('show')

  $(document).on 'click', '.full-calendar-services-toggle', ->
    if !($(this).hasClass('active'))
      toggleServiceButtons($(this))
      protocol_id = $(this).data('protocolId')
      statuses_hidden = $(this).data('statusesHidden')
      $.ajax
        method: 'get'
        dataType: 'script'
        url: "/service_calendars/view_full_calendar"
        data:
          portal: 'true'
          protocol_id: protocol_id
          statuses_hidden: statuses_hidden
          display_all_services: $(this).is('#all-services')

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

(exports ? this).setup_xeditable_fields = (scroll) ->
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

  $('td.your-cost').editable
    display: (value) ->
      # display field as currency, edit as quantity
      $(this).text("$" + parseFloat(value).toFixed(2))
    params: (params) ->
      {
        line_item:
          displayed_cost: params.value
        service_request_id: getSRId()
      }
    success: (response, newValue) ->
      $('.study_level_activities').bootstrapTable('refresh', silent: true)

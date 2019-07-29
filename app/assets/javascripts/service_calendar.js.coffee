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
        page:                     $(this).parents('.service-calendar-container').data('page')

  #####################
  # Change Visit Page #
  #####################

  $(document).on 'change', '.visit-group-select .selectpicker', ->
    $.ajax
      method: 'GET'
      dataType: 'script'
      url: $(this).data('url')
      data:
        page: $(this).find('option:selected').data('page')
        show_unchecked: $('#show_unchecked').val()

  ###########################
  # Update Move Visit Modal #
  ###########################

  $(document).on 'change', '#moveVisitForm #visit_group_id', ->
    $('#moveVisitForm #position').val('').selectpicker('refresh')
    $.ajax
      type: 'GET'
      dataType: 'script'
      url: '/service_calendars/show_move_visits'
      data: $('#moveVisitForm').serialize()

  $(document).on 'change', '#moveVisitForm #position', ->
    $.ajax
      type: 'GET'
      dataType: 'script'
      url: '/service_calendars/show_move_visits'
      data: $('#moveVisitForm').serialize()

  ################################
  # Calendar Tab Services Toggle #
  ################################

  $(document).on 'change', '#servicesToggle', ->
    $.ajax
      type: 'GET'
      dataType: 'script'
      url: '/service_calendars/merged_calendar'
      data:
        srid: getSRId
        ssrid: getSSRId
        show_unchecked: $(this).prop('checked')

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

(exports ? this).adjustCalendarHeaders = () ->
  $('.service-calendar-container').each ->
    $head   = $(this).children('.card-header')
    $row1   = $(this).find('.service-calendar-table > thead > tr:first-child')
    $row2   = $(this).find('.service-calendar-table > thead > tr:nth-child(2)')
    $row3   = $(this).find('.service-calendar-table > thead > tr:nth-child(3)')

    headHeight  = $head.outerHeight()
    row1Height  = $row1.outerHeight()
    row2Height  = $row2.outerHeight()
    row3Height  = $row3.outerHeight()

    $row2.children('th').css('top', headHeight + row1Height)
    $row3.children('th').css('top', headHeight +  row1Height + row2Height)

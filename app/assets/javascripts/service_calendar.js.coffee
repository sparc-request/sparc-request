# Copyright © 2011-2022 MUSC Foundation for Research Development
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

$ ->
  if $('#serviceCalendar').length
    adjustCalendarHeaders()

  $(document).on('mouseenter focus', '.editable:not(.active)', ->
    $(this).find('a').addClass('active')
  ).on('mouseleave focusout', '.editable:not(.active)', ->
    $(this).find('a').removeClass('active')
  )

  #########################
  # Load Tab on Page Load #
  #########################

  if $('#serviceCalendar .nav-tabs').length
    loadServiceCalendar()

  $(document).on('hide.bs.collapse', '.service-calendar-container .collapse', ->
    $(this).find('.service-calendar-table thead tr th').css('top', 0)
    $('.visit-group-popover').popover('dispose')
    $('.visit-popover').popover('dispose')
  ).on('shown.bs.collapse', '.service-calendar-container .collapse', ->
    adjustCalendarHeaders()
  )

  ##########################
  # Visit Checkbox / Input #
  ##########################

  $(document).on 'show.bs.modal', 'body', ->
    if $('.visit-group.active').length
      hideVisitGroupPopover()

  # Various calendar links
  $(document).on 'click keyup', 'th.visit-group, td.visit.billing-strategy-visit, td.notes, td.displayed-cost, td.subject-count, td.units-per-quantity, td.quantity', (event) ->
    if !$(this).hasClass('visit-group')
      hideVisitGroupPopover()

    # Click or press <return> to open
    if ((event.type == 'click' && event.target.tagName != 'A') || (event.type == 'keyup' && event.keyCode == 13)) && $(this).hasClass('editable') && $link = $(this).find('a:not(.disabled)')
      $.ajax
        method: $link.data('method') || 'GET'
        dataType: 'script'
        url: $link.attr('href')

  # Check row / column
  $(document).on 'click keyup', 'th.check-column.editable, td.check-row.editable', (event) ->
    hideVisitGroupPopover()
    # Click or press <return> to open
    if ((event.type == 'click' && event.target.tagName != 'A') || (event.type == 'keyup' && event.keyCode == 13))
      handleConfirm(this.querySelector('a'))

  # Template checkbox
  $(document).on 'click', 'td.visit.template-visit', (event) ->
    hideVisitGroupPopover()
    # Click or press <return> to open
    if ((event.type == 'click' && event.target.tagName != 'INPUT') || (event.type == 'keyup' && event.keyCode == 13))
      $(this).find('input').click()

  $(document).on 'change', '.visit-quantity', ->
    hideVisitGroupPopover()
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

  $(document).on 'changed.bs.select', '.visit-group-select .selectpicker', ->
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

  $(document).on 'change', '#visit_group_position', ->
    $form   = $(this).parents('form')
    action  = if $form.is('#new_visit_group') then 'new' else 'edit'
    $.ajax
      type: 'GET'
      dataType: 'script'
      url: "#{$form.attr('action')}/#{action}"
      data: $form.serialize()

  $(document).on 'click', '.change-visit-btn', (e) ->
    $form = $(this).parents('form')
    $form.append("<input type='hidden' name='change_visit' value=#{$(this).data('new-visit')}>")

  $(document).on 'click', '.change-billing-visit-btn', (e) ->
    $form = $(this).parents('form')
    $form.append("<input type='hidden' name='change_billing_visit' value=#{$(this).data('new-visit')}>")

  $(document).on 'click', '.visit-popover .btn-close', ->
    $(this).parents('.visit-popover').popover('dispose')

  ################################
  # Calendar Tab Services Toggle #
  ################################

  $(document).on 'change', '#servicesToggle', ->
    method = if $('#consolidated').val() == 'true' then 'view_full_calendar' else 'merged_calendar'

    $.ajax
      type: 'GET'
      dataType: 'script'
      url: "/service_calendars/#{method}"
      data:
        srid: getSRId()
        ssrid: getSSRId()
        show_draft: $('#show_draft').val()
        show_unchecked: $(this).prop('checked')

(exports ? this).loadServiceCalendar = () ->
  $.ajax
    method: 'get'
    dataType: 'script'
    url: $('#serviceCalendar .nav-tabs .nav-link.active').attr('href')
    success: ->
      $('#calendarLoading').removeClass('show active')

(exports ? this).adjustCalendarHeaders = () ->
  zIndex = $('.service-calendar-container').length * 5

  $('.service-calendar-container').each ->
    $head   = $(this).children('.card-header')
    $row1   = $(this).find('.service-calendar-table > thead > tr:first-child')
    $row2   = $(this).find('.service-calendar-table > thead > tr:nth-child(2)')
    $row3   = $(this).find('.service-calendar-table > thead > tr:nth-child(3)')

    headHeight  = $head.outerHeight()
    row1Height  = $row1.outerHeight()
    row2Height  = $row2.outerHeight()
    row3Height  = $row3.outerHeight()

    $head.css('z-index': zIndex)
    zIndex -= 2
    $row1.children('th').css({ 'top': headHeight, 'z-index': zIndex })
    $row1.children('th.visit-group-select').css({ 'z-index': zIndex + 1 })
    zIndex--
    $row2.children('th').css({ 'top': headHeight + row1Height, 'z-index': zIndex })
    zIndex--
    $row3.children('th').css({ 'top': headHeight +  row1Height + row2Height, 'z-index': zIndex })
    zIndex--

(exports ? this).toggleServicesToggle = (toggleOn) ->
  if toggleOn
    $('#servicesToggle').parents('.toggle').removeClass('invisible')
  else
    $('#servicesToggle').parents('.toggle').addClass('invisible')

(exports ? this).hideVisitGroupPopover = () ->
  $('.visit-group.active').removeClass('active').trigger('focusout').popover('hide').popover('dispose')

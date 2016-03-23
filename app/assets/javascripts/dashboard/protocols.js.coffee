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

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $(document).on 'click', '.view-full-calendar-button', ->
    protocol_id = $(this).data('protocol-id')
    $.ajax
      method: 'get'
      url: "/dashboard/service_calendars/view_full_calendar.js?portal=true&protocol_id=#{protocol_id}"

#  Sparc.protocol =
#    ready: ->
#      $('.permissions-dialog').dialog
#        autoOpen:false
#        dialogClass: 'permissions_dialog'
#        title: "User Rights"
#        width: 400
#        height: 300
#        model: true
#        buttons:
#          'Ok': () ->
#            $(this).dialog('close')
#
#      $(document).on 'click', '.service-request-button', ->
#        if $(this).data('permission')
#          window.location = $(this).data('url')
#        else
#          $('.permissions-dialog').dialog('open')
#          $('.permissions-dialog .text').html('Edit.')
#
#      $(document).on 'click', '.add-services-button', ->
#        if !$(this).data('permission')
#          $('.permissions-dialog').dialog('open')
#          $('.permissions-dialog .text').html('Edit.')
#
#      $('.edit-protocol-information-dialog').dialog
#        autoOpen: false
#        title: 'Edit Study Information'
#        width: 715
#        height: 500
#        modal: true
#        buttons:
#          'Submit': () ->
#            disableButton()
#            form = $('.edit-protocol-information-dialog').children('form')
#            form.bind('ajax:success', (data) ->
#              enableButton()
#              $('.edit-protocol-information-dialog').dialog('close')
#              Sparc.protocol.renderProtocolAccordionList()
#            ).submit()
#          'Cancel': () ->
#            $(this).dialog('close')
#
#      $('.view-sub-service-request-dialog').dialog
#        autoOpen: false
#        dialogClass: 'view_request_dialog_box'
#        title: 'Service Information'
#        width: 900
#        height: 700
#        modal: true
#        buttons:
#          'Print': () ->
#            id = $('#id').val()
#            ssr_id = $('#ssr_id').val()
#            printerFriendly = window.open("/dashboard/service_requests/#{id}?ssr_id=#{ssr_id}")
#            printerFriendly.print()
#          'Ok': () ->
#            $(this).dialog('close')
#
#      $('.view-full-calendar-dialog').dialog
#        autoOpen: false
#        dialogClass: 'full_calendar_dialog_box'
#        title: 'Study Information'
#        width: 900
#        height: 700
#        modal: true
#        buttons: [
#          {
#            text: 'Print'
#            click: ->
#              calendar_id = $('#calendar_id').val()
#              printerFriendly = window.open("/dashboard/protocols/#{calendar_id}/view_full_calendar")
#              printerFriendly.print()
#          }
#          {
#          id: 'ok_button'
#          text: 'Ok'
#          click: ->
#            $(this).dialog('close')
#          }
#        ]
#
#
#      # Sparc.protocol.renderProjectAccordionList()
#      load_Page = -> Sparc.protocol.renderProtocolAccordionList()
#      setTimeout load_Page, 2000
#
#      $('#productivity-accordion').accordion
#        heightStyle: 'content'
#        event: 'mouseover'
#        collapsible: true
#
#      $('.draggable')
#        .draggable
#          containment: 'document'
#          appendTo: 'body'
#          helper: 'clone'
#          cursor: 'url(closedhand.cur),move'
#          cursorAt: {left: 5}
#          revert: 'invalid'
#        .mouseenter (element) ->
#          createTip(element) unless $(this).hasClass('ui-draggable-disabled')
#        .mousemove (element) ->
#          $('#tip').css({ left: element.pageX + 30, top: element.pageY - 16 })
#        .mouseleave ->
#          $('#tip').remove()
#
#      $('.droppable').droppable
#        tolerance: 'touch'
#        activeClass: 'drop-active'
#        hoverClass: 'drop-hover'
#        drop: (event, ui) ->
#          element = $(ui.draggable).clone()
#          switch element.data('type')
#            when 'grant' then $(this).children('.grants-list').append(element)
#            when 'publication' then $(this).children('.publications-list').append(element)
#            else null
#          ui.draggable.draggable('disable')
#
#      $(document).on 'click', '#previous', ->
#        Sparc.protocol.navigateCostTable('decrease') unless $(this).attr('disabled') == 'disabled'
#
#      $(document).on 'click', '#next', ->
#        Sparc.protocol.navigateCostTable('increase') unless $(this).attr('disabled') == 'disabled'
#
#    disableButton: (containing_text, change_to) ->
#      button = $(".ui-dialog .ui-button:contains(#{containing_text})")
#      button.html("<span class='ui-button-text'>#{change_to}</span>")
#        .attr('disabled', true)
#        .addClass('button-disabled')
#
#    enableButton: (containing_text, change_to) ->
#      button = $(".ui-dialog .ui-button:contains(#{containing_text})")
#      button.html("<span class='ui-button-text'>#{change_to}</span>")
#        .attr('disabled', false)
#        .removeClass('button-disabled')
#
#    navigateCostTable: (direction) ->
#      visitsArray = JSON.parse($('#visits_array').val())
#      visit_group_num = parseInt($('#visit_group_num').val())
#      if direction == 'increase'
#        visit_group_num += 1 unless visit_group_num == (visitsArray.length - 1)
#      else if direction == 'decrease'
#        visit_group_num -= 1 unless visit_group_num == 0
#      Sparc.protocol.disableButton(">",">") if visit_group_num == (visitsArray.length - 1)
#      Sparc.protocol.enableButton(">",">") if visit_group_num < (visitsArray.length - 1)
#      Sparc.protocol.disableButton("<","<") if visit_group_num == 0
#      Sparc.protocol.enableButton("<","<") if visit_group_num > 0
#      $('.visit_quantity').html('')
#      $('.visit_header').html('')
#      i = 0
#      for item in visitsArray[visit_group_num]
#        i += 1
#        $("#column_#{i}").html(item.visit_num)
#        for visit in item.values
#          display_cost = visit.cost / 100
#          _display_cost = if isNaN(display_cost)
#            'N/A'
#          else
#            '$' + display_cost.toFixed(2)
#          $("#quantity_#{visit.service_id}_column_#{i}").html(_display_cost)
#      $('#visit_group_num').val(visit_group_num)
#
#
#  #  Protocol Index Begin
#  $(document).on 'click', '.protocols_index_row > .id,.title,.pis', ->
#    #if you click on the row, it opens the protocol show
#    protocol_id = $(this).parent().data('protocol-id')
#    window.location = "/dashboard/protocols/#{protocol_id}"
#
#  $(document).on 'click', '.requests_display_link', ->
#    # Opens the requests modal
#    protocol_id = $(this).parents("tr").data('protocol-id')
#    $.ajax
#      type: 'get'
#      url: "/dashboard/protocols/#{protocol_id}/display_requests"
#
#  $(document).on 'click', '.protocol-archive-button', ->
#    protocol_id = $(this).parents("tr").data('protocol-id')
#    $.ajax
#      type: 'PATCH'
#      url:  "/dashboard/protocols/#{protocol_id}/archive.js"
#      data: { protocol_id: protocol_id }
#
#  $(document).on 'click', '#save_filters_link', ->
#    data = {} #Grab form values
#    $.each $('form#filterrific-no-ajax-auto-submit').serializeArray(), (i, field) ->
#      data[field.name] = field.value
#    $.ajax
#      type: 'GET'
#      url:  @href
#      data: data
#    return false
#
#  $(document).on 'click', '#reset_filters_link, .saved_search_link', ->
#    # This makes the reset filter and saved search links go through AJAX
#    $.getScript @href
#    false
#
#  $(document).on 'click', '.pagination a', ->
#    # This makes the pagination links go through AJAX, rather than link hrefs
#    $('.pagination').html 'Page is loading...'
#    $.getScript @href
#    false
#  #  Protocol Index End
#
#  # Protocol Show Begin
#  $(document).on 'click', '.edit-protocol-information-button', ->
#    if $(this).data('permission')
#      protocol_id = $(this).data('protocol-id')
#      window.location = "/dashboard/protocols/#{protocol_id}/edit"
#    else
#      $('.permissions-dialog').dialog('open')
#      $('.permissions-dialog .text').html('Edit.')
#
#  $(document).on 'click', '.view-sub-service-request-button', ->
#    id = $(this).data('sub-service-request-id')
#    $.ajax
#      method: 'GET'
#      url: "/dashboard/sub_service_requests/#{id}.js"
#
#  $(document).on 'click', '.edit_service_request', ->
#    if $(this).data('permission')
#      window.location = $(this).data('url')
#    else
#      $('.permissions-dialog').dialog('open')
#      $('.permissions-dialog .text').html('Edit.')
#  # Protocol Show End
#
#  # Protocol Edit Begin
#  $(document).on 'click', '#protocol_type_button', ->
#    protocol_id = $(this).data('protocol-id')
#    data = type : $("#protocol_type").val()
#    if confirm "This will change the type of this Project/Study.  Are you sure?"
#      $.ajax
#        type: 'PATCH'
#        url: "/dashboard/protocols/#{protocol_id}/update_protocol_type"
#        data: data
#  # Protocol Edit End

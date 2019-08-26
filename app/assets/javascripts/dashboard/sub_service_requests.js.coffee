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

$ ->
  if $('#subServiceRequestDetails').length
    $.ajax
      method: 'get'
      dataType: 'script'
      url: $('#subServiceRequestDetails .nav-tabs .nav-link.active').attr('href')
      success: ->
        $('#requestLoading').removeClass('show active')

  refreshFulfillmentButton = ->
   refresh = window.setInterval((->
      imported_to_fulfillment = $('#fulfillmentStatus').data('imported-to-fulfillment')
      if imported_to_fulfillment == false
        $("#nprogress").hide()
        $("#ssr_fulfillment_status").load(location.href + " #fulfillmentStatus")
        $("#nprogress").hide()
      else
        window.clearInterval refresh
      return
    ), 5000)
   
  # SERVICE REQUEST INFO LISTENERS BEGIN
  if $('#fulfillmentStatus').length
    refreshFulfillmentButton()

  $(document).on 'change', '#sub_service_request_owner', ->
    ssr_id = $(this).data('sub_service_request_id')
    owner_id = $(this).val()
    data = 'sub_service_request' : 'owner_id' : owner_id
    $.ajax
      type: 'PATCH'
      url: "/dashboard/sub_service_requests/#{ssr_id}"
      data: data

  $(document).on 'change', '#sub_service_request_status', ->
    ssr_id = $(this).data('sub_service_request_id')
    status = $(this).val()
    data = 'sub_service_request' : 'status' : status
    $.ajax
      type: 'PUT'
      url: "/dashboard/sub_service_requests/#{ssr_id}"
      data: data

  $(document).on 'click', '#pushToFulfillment', ->
    $(this).prop('disabled', true)
    $.ajax
      type: 'PATCH'
      dataType: 'script'
      url: "/dashboard/sub_service_requests/#{getSSRId()}"
      data:
        sub_service_request:
          in_work_fulfillment: 1
      success: ->
        refreshFulfillmentButton()

  $(document).on 'click', '#pushToEpic', ->
    $(this).prop('disabled', true)
    $.ajax
      method: 'PUT'
      dataType: 'script'
      url: "/dashboard/sub_service_requests/#{getSSRId()}/push_to_epic"

  $(document).on 'click', '#resend-surveys-button', ->
    $(this).prop('disabled', true)
    ssr_id = $(this).data('sub-service-request-id')
    $.ajax
      type: 'PUT'
      url: "/dashboard/sub_service_requests/#{ssr_id}/resend_surveys"
      success: ->

  # SERVICE REQUEST INFO LISTENERS END
  # ADMIN TAB LISTENER BEGIN

  $(document).on 'click', '.ssr_tab a', ->
    Cookies.set('admin-tab', $(this).attr('id'), { path: '/' })
    ##Refresh Tabs Ajax
    protocol_id = $(this).parents('ul').data('protocol-id')
    ssr_id = $(this).parents('ul').data('ssr-id')
    partial_name = $(this).data('partial-name')

    $.ajax
      type: 'GET'
      url: "/dashboard/sub_service_requests/#{ssr_id}/refresh_tab"
      data: {"protocol_id": protocol_id, "ssr_id": ssr_id, "partial_name": partial_name}

  # ADMIN TAB LISTENER END
  # STUDY SCHEDULE TAB BEGIN

  $(document).on 'click', '.ss_tab a', ->
    Cookies.set('admin-ss-tab', $(this).attr('id'), { path: '/' })

  $(document).on 'click', '.service_calendar_row', ->
    if confirm(I18n.t('calendars.confirm_row_select'))
      $.ajax
        type: 'post'
        url: $(this).data('url')

  $(document).on 'click', '.service_calendar_column', ->
    if confirm(I18n.t('calendars.confirm_column_select'))
      $.ajax
        type: 'post'
        url: $(this).data('url')

  # STUDY SCHEDULE TAB END
  # TIMELINE LISTENERS BEGIN

  $(document).on 'dp.hide', '#sub_service_request_consult_arranged_date_picker', ->
    ssr_id = $(this).data('sub_service_request_id')
    consult_arranged_date = $(this).val()
    data = 'sub_service_request' : 'consult_arranged_date' : consult_arranged_date
    $.ajax
      type: 'PATCH'
      url: "/dashboard/sub_service_requests/#{ssr_id}"
      data: data

  $(document).on 'dp.hide', '#sub_service_request_requester_contacted_date_picker', ->
    ssr_id = $(this).data('sub_service_request_id')
    requester_contacted_date = $(this).val()
    data = 'sub_service_request' : 'requester_contacted_date' : requester_contacted_date
    $.ajax
      type: 'PATCH'
      url: "/dashboard/sub_service_requests/#{ssr_id}"
      data: data

  # TIMELINE LISTENERS END
  # HISTORY LISTENERS BEGIN

  $(document).on 'click', '.history_button', ->
    $('#history-spinner').removeClass('hidden')
    ssr_id = $(this).data("sub-service-request-id")
    data = 'partial': $(this).data('table')
    $.ajax
      type: 'GET'
      url: "/dashboard/sub_service_requests/#{ssr_id}/change_history_tab"
      data: data
      success: ->
        $('#history-spinner').addClass('hidden')


  # HISTORY LISTENERS END

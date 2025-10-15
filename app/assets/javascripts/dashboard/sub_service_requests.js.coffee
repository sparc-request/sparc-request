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
  consultArrangedDate = null
  requesterContactedDate = null

  # Load tab on page load
  if $('#subServiceRequestDetails').length
    $.ajax
      method: 'get'
      dataType: 'script'
      url: $('#subServiceRequestDetails .nav-tabs .nav-link.active').attr('href')
      success: ->
        $('#requestLoading').removeClass('show active')
        consultArrangedDate = $('#consultArrangedDatePicker input').val()
        requesterContactedDate = $('#requesterContactedDatePicker input').val()

  ##############
  # SSR Header #
  ##############

  refreshFulfillmentButton = ->
    refresh = window.setInterval((->
      imported_to_fulfillment = $('#fulfillmentStatus').data('imported')
      request_invalid = $('#fulfillmentStatus.request_invalid').length
      if imported_to_fulfillment or request_invalid
        window.clearInterval refresh
      else
        $.get window.location.href + ".html", (data) ->
          $("#fulfillmentStatusContainer").replaceWith($(data).find('#fulfillmentStatusContainer'))
          initializeTooltips()
      return
    ), 5000)

  # This manages the bulk status edit checkboxes on dashboard > protocols > requests section
  $(document).on 'click', '.service-requests-table #select-all', ->
    checked = $(this).prop('checked')
    $('.service-requests-table tbody tr input[type="checkbox"]').each (index, row) ->
      $(this).prop('checked', checked)

  $(document).on 'change', '.service-requests-table input[type="checkbox"]', ->
    if $('.service-requests-table input[type="checkbox"][name^="select-ssr"]:checked').length <= 1
      $('.bulk-status-edit').addClass('disabled')
    else
      $('.bulk-status-edit').removeClass('disabled')

    if $('.service-requests-table input[type="checkbox"][name^="select-ssr"]:checked').length == $('.service-requests-table input[type="checkbox"][name^="select-ssr"]').length
      $('.service-requests-table #select-all').prop('checked', true)
    else
      $('.service-requests-table #select-all').prop('checked', false)

  $(document).on 'click', '.bulk-status-edit', ->
    id_numbers = []
    $('.service-requests-table input[type="checkbox"][name^="select-ssr"]:checked').each (index, row) ->
      id_numbers.push(this.value)
    
    $.ajax
      type: 'GET'
      dataType: 'script'
      url: "/dashboard/sub_service_requests/bulk_status_edit"
      data:
        id:
          id_numbers
      # success: ->
      #   refreshFulfillmentButton()

  $(document).on 'click', '.bulk-status-dropdown-item', ->
    $(this).parent('.dropdown-toggle').removeClass('text-success text-danger border-success border-danger')
    $(this).parent('.dropdown-toggle').addClass('text-warning')

  $(document).on 'click', '#bulk_status_submit_button', ->
    $.ajax
      type: 'POST'
      dataType: 'script'
      url: "/dashboard/sub_service_requests/bulk_status_update"
      data:
        ids:
          $('#ssr_ids').val().split(' ')
        status:
          $('#status_select_dropdown').val()
    
    

  # SERVICE REQUEST INFO LISTENERS BEGIN
  if $('#fulfillmentStatus').length
    refreshFulfillmentButton()

  $(document).on 'click', '#pushToFulfillment:not(.disabled)', ->
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

  $(document).on 'click', '#synchToFulfillment:not(.disabled)', ->
    $(this).prop('disabled', true)
    $.ajax
      type: 'PUT'
      dataType: 'script'
      url: "/dashboard/sub_service_requests/#{getSSRId()}/synch_to_fulfillment"
      # success: ->
      #   refreshFulfillmentButton()

  $(document).on 'click', '#pushToEpic:not(.disabled)', ->
    $(this).prop('disabled', true)
    $.ajax
      method: 'PUT'
      dataType: 'script'
      url: "/dashboard/sub_service_requests/#{getSSRId()}/push_to_epic"
      success: ->
        $(this).prop('disabled', false)

  ###############
  # Details Tab #
  ###############

  # Approvals
  $(document).on 'change', '.approval-check', ->
    $check = $(this)
    $check.prop('checked', false)
    ConfirmSwal.fire({}).then (result) ->
      if result.value
        $check.prop('checked', true)
        approval = $check.val()
        $check.prop('disabled', true)

        $.ajax
          method: 'put'
          dataType: 'script'
          url: "/dashboard/sub_service_requests/#{getSSRId()}/update_approval"
          data:
            sub_service_request:
              approval: approval

  # Milestones
  $(document).on 'keyup', '#consultArrangedDatePicker input, #requesterContactedDatePicker input', (event) ->
    key = event.keyCode || event.charCode
    if !$(this).val() && [8, 46].includes(key) # Backspace or Delete keys
      data = $(this).serialize()

      $.ajax
        method: 'put'
        dataType: 'script'
        url: "/dashboard/sub_service_requests/#{getSSRId()}"
        data: data

  $(document).on 'change.datetimepicker', '#consultArrangedDatePicker', (event) ->
    val = $(this).find('input').val()

    if (val != consultArrangedDate)
      data = $(this).find('input').serialize()

      $.ajax
        method: 'put'
        dataType: 'script'
        url: "/dashboard/sub_service_requests/#{getSSRId()}"
        data: data

  $(document).on 'change.datetimepicker', '#requesterContactedDatePicker', (event) ->
    val = $(this).find('input').val()

    if (val != requesterContactedDate)
      data = $(this).find('input').serialize()

      $.ajax
        method: 'put'
        dataType: 'script'
        url: "/dashboard/sub_service_requests/#{getSSRId()}"
        data: data

  ##############################
  # Study Level Activities Tab #
  ##############################

  $(document).on 'change', '#studyLevelActivitiesForm #line_item_service_id', ->
    if $('#studyLevelActivitiesForm').hasClass('new_line_item')
      $.ajax
        method: 'get'
        dataType: 'script'
        url: '/dashboard/study_level_activities/new'
        data: $('#studyLevelActivitiesForm').serialize()
    else
      $.ajax
        method: 'get'
        dataType: 'script'
        url: $('#studyLevelActivitiesForm').prop('action') + "/edit"
        data: $('#studyLevelActivitiesForm').serialize()

  $(document).on 'click', '#admin_rate_reset_button', ->
    $.ajax
      method: 'post'
      dataType: 'script'
      url: $('form.edit_line_item').prop('action') + "/reset_admin_rate"
      data:
        srid: getSRId()
        ssrid: getSSRId()

  # SERVICE REQUEST INFO LISTENERS END

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
      if imported_to_fulfillment
        window.clearInterval refresh
      else
        $.get window.location.href + ".html", (data) ->
          $("#fulfillmentStatusContainer").replaceWith($(data).find('#fulfillmentStatusContainer'))
          initializeTooltips()
      return
    ), 5000)

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
        data = $check.serialize()
        $check.prop('disabled', true)

        $.ajax
          method: 'put'
          dataType: 'script'
          url: "/dashboard/sub_service_requests/#{getSSRId()}"
          data: data

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

    if val != consultArrangedDate
      data = $(this).find('input').serialize()

      $.ajax
        method: 'put'
        dataType: 'script'
        url: "/dashboard/sub_service_requests/#{getSSRId()}"
        data: data

  $(document).on 'change.datetimepicker', '#requesterContactedDatePicker', (event) ->
    val = $(this).find('input').val()

    if val != requesterContactedDate
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
    if $('#studyLevelActivitiesForm').hasClass('.new_line_item')
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

  # SERVICE REQUEST INFO LISTENERS END

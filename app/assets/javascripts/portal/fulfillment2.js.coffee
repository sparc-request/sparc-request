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

(exports ? this).do_datepicker = (selector) ->
  $(selector).datepicker
    constrainInput: true
    dateFormat: 'm/dd/yy'
    altFormat: 'yy-mm-dd'
    altField: "#{selector.replace('_picker', '')}"

$(document).ready ->
  originalContent = null

  Sparc.datepicker = {
    ready: (selector) ->
      data = $(selector).siblings('.fulfillment_data')
      $(selector).datepicker
        constrainInput: true
        dateFormat: 'm/dd/yy'
        altFormat: 'yy-mm-dd'
        altField: data

  }

  $(document).on('change', '.datepicker', ->
    selector = "##{$(this).attr("id").replace('_picker', '')}"
    $("#{selector}").change()
    )
  original = ''
  $(document).on('click', '.datepicker', ->
    original = $(this).val()
    )

  for datepicker in $('.datepicker')
    do_datepicker("##{$(datepicker).attr('id')}")

  validateDate = (start,end) ->
    if start == '' or end ==''
      return true
    if start > end
      return false
    else
      return true

  filterNonKeys = (arr) ->
    filtered = []
    i = arr.length
    re = /^.*_id/
    (filtered.push arr[i] if re.test(arr[i])) while i--
    return filtered

  # WARNING: Object.keys(obj) does not work in IE 6,7,or 8.  Please do not use.
  getObjKlass = (obj) ->
    objData = $(obj).data()
    objKeys = $.map(objData, (val, key) ->
      key
    )
    # Filter out anything that does not end with _id
    filtered_keys = filterNonKeys(objKeys)
    filtered_keys[0].replace('_id', '')

  $(document).on('change', '.fulfillment_data', ->
    klass = getObjKlass(this)
    object_id = $(this).data("#{klass}_id")
    name = $(this).attr('name')
    key = name.replace("#{klass}_", '')
    data = {}
    data[key] = $(this).val()
    data['study_tracker'] = $('#study_tracker_hidden_field').val() || null
    data['line_items_visit_id'] = $(this).parents("tr").data("line_items_visit_id") || null
    if $(this).attr('name') == 'protocol_start_date' or $(this).attr('name') == 'protocol_end_date'
      start = $('#protocol_start_date_picker').datepicker("getDate")
      end = $('#protocol_end_date_picker').datepicker("getDate")
      if validateDate(start,end)
        put_attribute(object_id, klass, data)
      else
        $().toastmessage('showErrorToast', I18n["fulfillment_js"]["date_error"])
        $("##{$(this).attr("name")}_picker").val(original)
    else
      put_attribute(object_id, klass, data)
  )

  $(document).on('change', '.cwf_data', ->
    klass = getObjKlass(this)
    object_id = $(this).data("#{klass}_id")
    data = {'in_work_fulfillment': $(this).prop('checked')}
    $('#cwf_building_dialog').dialog('open')
    put_attribute(object_id, klass, data, cwf_callback)
    $(this).attr("disabled", "disabled")
    $('#study_tracker_access div.ui-button').css("display", "inline-block")
  )

  $(document).on('click', '.delete_data', ->
    klass = getObjKlass(this)
    object_id = $(this).data("#{klass}_id")
    has_fulfillments = $(this).data("has_fulfillments") || null
    if has_fulfillments
      alert(I18n["has_fulfillments"])
    else
      data = {}
      data['study_tracker'] = $('#study_tracker_hidden_field').val() || null
      confirm_message = I18n["fulfillment_js"]["remove_service"]
      if $(this).data("has_popup") == true
        if confirm(confirm_message)
          $.ajax
            type: 'DELETE'
            url:  "/portal/admin/#{klass}s/#{object_id}"
            data: JSON.stringify(data)
            dataType: "script"
            contentType: 'application/json; charset=utf-8'
            success: ->
              $().toastmessage('showSuccessToast', "#{klass.humanize()}" + I18n["fulfillment_js"]["deleted"]);
      else
        $.ajax
          type: 'DELETE'
          url:  "/portal/admin/#{klass}s/#{object_id}"
          data: JSON.stringify(data)
          dataType: "script"
          contentType: 'application/json; charset=utf-8'
          success: ->
            $().toastmessage('showSuccessToast', "#{klass.humanize()}" + I18n["fulfillment_js"]["deleted"]);
  )

  $('#cwf_building_dialog').dialog
    dialogClass: "no-close"
    autoOpen: false
    height: 80
    width: 650
    modal: true
    resizable: false

  cwf_callback = ->
    $('#cwf_building_dialog').dialog('close')


  put_attribute = (id, klass, data, callback) ->
    callback ?= -> return null
    $.ajax
      type: 'PUT'
      url:  "/portal/admin/#{klass}s/#{id}/update_from_fulfillment"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf-8'
      success: ->
        $().toastmessage('showSuccessToast', I18n["service_request_success"])
        callback()
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showErrorToast', "#{error.humanize()}.");

  $(document).on('click', '.cwf_delete_data', ->
    klass = getObjKlass(this)
    object_id = $(this).data("#{klass}_id")
    has_fulfillments = $(this).data("has_fulfillments") || null
    if has_fulfillments
      alert(I18n["has_fulfillments"])
    else
      data = {}
      data['study_tracker'] = $('#study_tracker_hidden_field').val() || null
      confirm_message = I18n["fulfillment_js"]["cwf_service_delete"]
      if confirm(confirm_message)
        $.ajax
          type: 'DELETE'
          url:  "/portal/admin/line_items/#{object_id}"
          data: JSON.stringify(data)
          dataType: "script"
          contentType: 'application/json; charset=utf-8'
          success: ->
            $().toastmessage('showSuccessToast', I18n["service_deleted"])
  )

  $(document).on('click', '.expand_li', ->
    $(this).children().first().toggleClass('ui-icon-triangle-1-s')
    li_id = $(this).data('line_item_id')
    $(".li_#{li_id}").toggle()
  )

  #######################
  # VISIT CHANGE TOASTS #
  #######################
  $('.user_toast').each ->
    $().toastmessage('showToast', {
      text : $(this).data('message')
      sticky : true
      type : 'warning'
      close : => delete_closed_toast($(this).data('toast_id'))
    })

  delete_closed_toast = (toast_id) ->
    $.ajax
      type: 'DELETE'
      url:  "/portal/admin/delete_toast_message/#{toast_id}"

  send_to_epic = ->
    ssr_id = $(this).attr('sub_service_request_id')
    $().toastmessage('showToast', {
                     text: "Study is being sent to Epic",
                     sticky: true,
                     type: 'notice'
                     })
    $('.send_to_epic_button').off('click', send_to_epic)
    $.ajax
      type: 'PUT'
      url: "/portal/admin/sub_service_requests/#{ssr_id}/push_to_epic"
      contentType: 'application/json; charset=utf-8'
      success: ->
        $().toastmessage('showToast', {
                         text: I18n["fulfillment_js"]["epic"],
                         type: 'success',
                         sticky: true
                         })
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'application/json'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showToast', {
                           type: 'error',
                           text: "#{error.humanize()}.",
                           sticky: true
                           })
      complete: =>
        $('.send_to_epic_button').on('click', send_to_epic)

  $('.send_to_epic_button').on('click', send_to_epic)

  # INSTANTIATE HELPERS
  # set_percent_subsidy()
  $('#approval_history_table').tablesorter()
  $('#status_history_table').tablesorter()

  $(document).on('blur', '.to_zero', ->
    if $(this).val() == ''
      $(this).val(0).change()
  )

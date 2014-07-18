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
  original = 'hello'
  $(document).on('click', '.datepicker', ->
    original = $(this).val()
    )

  for datepicker in $('.datepicker')
    do_datepicker("##{$(datepicker).attr('id')}")

  validateDate = (start,end) ->
    if start == 'Enter valid date' or end =='Enter valid date'
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
      start = $('#protocol_start_date_picker').val()
      end = $('#protocol_end_date_picker').val()
      if validateDate(start,end)
        put_attribute(object_id, klass, data)
      else
        $().toastmessage('showErrorToast', "Please enter a start date before the end date")
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
    data = {}
    data['study_tracker'] = $('#study_tracker_hidden_field').val() || null
    confirm_message = "Are you sure that you want to remove this service from all subjects' visit calendars in this arm?"
    if $(this).data("has_popup") == true
      if confirm(confirm_message)
        $.ajax
          type: 'DELETE'
          url:  "/portal/admin/#{klass}s/#{object_id}"
          data: JSON.stringify(data)
          dataType: "script"
          contentType: 'application/json; charset=utf-8'
          success: ->
            $().toastmessage('showSuccessToast', "#{klass.humanize()} has been deleted.");
    else
      $.ajax
        type: 'DELETE'
        url:  "/portal/admin/#{klass}s/#{object_id}"
        data: JSON.stringify(data)
        dataType: "script"
        contentType: 'application/json; charset=utf-8'
        success: ->
          $().toastmessage('showSuccessToast', "#{klass.humanize()} has been deleted.");
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
    callback ?= -> return null;
    $.ajax
      type: 'PUT'
      url:  "/portal/admin/#{klass}s/#{id}/update_from_fulfillment"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf-8'
      success: ->
        $().toastmessage('showSuccessToast', "Service request has been saved.")
        callback()
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showErrorToast', "#{error.humanize()}.");

  $(document).on('click', '.add_fulfillment_link', ->
    data = {'fulfillment': {'line_item_id': $(this).data('line_item_id')}}
    $.ajax
      type: 'POST'
      url:  "/portal/admin/fulfillments/"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf-8'
  )

  $(document).on('change', '#arm_id', ->
    $("#visit_position").attr('disabled', 'disabled')
    $("#delete_visit_position").attr('disabled', 'disabled')
    sr_id = $(this).data('service_request_id')
    protocol_id = $('#arm_id').data('protocol_id')
    data =
      'sub_service_request_id': $(this).data('sub_service_request_id')
      'service_request_id': sr_id
      'protocol_id': protocol_id
      'arm_id': $('#arm_id').val()
      'study_tracker': $('#study_tracker_hidden_field').val() || null
    $.ajax
      type: 'GET'
      url:  "/portal/admin/protocols/#{protocol_id}/change_arm"
      data:  data
      success: ->
        $("#visit_position").attr('disabled', false)
        $("#delete_visit_position").attr('disabled', false)
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showErrorToast', "#{error.humanize()}.");
  )

  $(document).on('click', '.add_arm_link', ->
    $('#arm-form').dialog('open')
  )

  $('#arm-form').dialog
    autoOpen: false
    height: 275
    width: 300
    modal: true
    resizable: false
    buttons: [
      {
        id: "submit_arm"
        text: "Submit"
        click: ->
          $("#arm-form").submit()
          $(this).dialog('close')
      },
      {
        id: "cancel_arm"
        text: "Cancel"
        click: ->
          $(this).dialog('close')
      }]
    open: ->
      originalContent = $('#arm-form').html()
    close: ->
      $('#arm-form').html(originalContent)

  $('#arm-form').submit ->
    sr_id = $('#arm_id').data('service_request_id')
    protocol_id = $('#arm_id').data('protocol_id')
    data =
      'sub_service_request_id': $('#arm_id').data('sub_service_request_id')
      'service_request_id': sr_id
      'protocol_id': protocol_id
      'arm_name': $('#arm_name').val()
      'subject_count': $('#subject_count').val()
      'visit_count': $('#visit_count').val()
    $.ajax
      type: 'POST'
      url:   "/portal/admin/protocols/#{protocol_id}/add_arm"
      data:  JSON.stringify(data)
      dataType: 'script'
      contentType: 'application/json; charset=utf-8'
      success: ->
        $().toastmessage('showSuccessToast', "Service request has been saved.")
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showErrorToast', "#{error.humanize()}.");

  $(document).on('click', '.remove_arm_link', ->
    if $(this).data('arm_count') <= 1
      alert("You can't delete the last arm while Per-Patient/Per Visit services still exist.")
    else if confirm("Are you sure you want to remove the ARM?")
      sr_id = $(this).data('service_request_id')
      protocol_id = $('#arm_id').data('protocol_id')
      data =
        'sub_service_request_id': $(this).data('sub_service_request_id')
        'service_request_id': sr_id
        'protocol_id': protocol_id
        'arm_id': $('#arm_id').val()
      $.ajax
        type: 'POST'
        url:   "/portal/admin/protocols/#{protocol_id}/remove_arm"
        data:  JSON.stringify(data)
        dataType: 'script'
        contentType: 'application/json; charset=utf-8'
        success: ->
          $().toastmessage('showSuccessToast', "Service request has been saved.")
        error: (jqXHR, textStatus, errorThrown) ->
          if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
            errors = JSON.parse(jqXHR.responseText)
          else
            errors = [textStatus]
          for error in errors
            $().toastmessage('showErrorToast', "#{error.humanize()}.");
  )
  
  $(document).on('click', '.add_visit_link', ->
    $('#visit-form').dialog('open')
  )

  $('#visit-form').dialog
    autoOpen: false
    height: 275
    width: 300
    modal: true
    resizable: false
    buttons: [
      {
        id: "submit_visit"
        text: "Submit"
        click: ->
          $("#visit-form").submit()
          $("#submit_visit").attr("disabled", true).addClass("ui-state-disabled")
      },
      {
        id: "cancel_visit"
        text: "Cancel"
        click: ->
          $(this).dialog('close')
      }]
    open: ->
      originalContent = $('#visit-form').html()
    close: ->
      $('#visit-form').html(originalContent)

  $('#visit-form').submit ->
    sr_id = $('.add_visit_link').data('service_request_id')
    data =
      'sub_service_request_id': $('.add_visit_link').data('sub_service_request_id')
      'service_request_id': sr_id
      'visit_position': $('#visit_position').val()
      'arm_id': $('#arm_id').val()
      'study_tracker': $('#study_tracker_hidden_field').val() || null
      'visit_name': $('#visit_name').val()
      'visit_day': $('#visit_day').val()
      'visit_window': $('#visit_window').val()
    $.ajax
      type: 'POST'
      url:   "/portal/admin/service_requests/#{sr_id}/add_per_patient_per_visit_visit"
      data:  JSON.stringify(data)
      dataType: 'script'
      contentType: 'application/json; charset=utf-8'
      success: ->
        $().toastmessage('showSuccessToast', "Service request has been saved.")
        $('#visit-form').dialog('close')
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showErrorToast', "#{error.humanize()}.");
      complete: ->
        $("#submit_visit").attr("disabled", false).removeClass("ui-state-disabled")

  $(document).on('click', '.delete_visit_link', ->
    sr_id = $(this).data('service_request_id')
    data =
      'sub_service_request_id': $(this).data('sub_service_request_id')
      'service_request_id': sr_id
      'visit_position': $('#delete_visit_position').val()
      'arm_id': $('#arm_id').val()
      'study_tracker': $('#study_tracker_hidden_field').val() || null
    $.ajax
      type: 'DELETE'
      url:   "/portal/admin/service_requests/#{sr_id}/remove_per_patient_per_visit_visit"
      data:  JSON.stringify(data)
      dataType: 'script'
      contentType: 'application/json; charset=utf-8'
      success: ->
        $().toastmessage('showSuccessToast', "Service request has been saved.")

      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showErrorToast', "#{error.humanize()}.");
  )

  $(document).on('click', '#add_service', ->
    ssr_id = $(this).data('sub_service_request_id')
    new_service_id = $(this).data('select_id')
    data = 
      'sub_service_request_id': ssr_id
      'new_service_id': $("##{new_service_id}").val()
      'arm_id': $('#arm_id').val()
      'study_tracker': $('#study_tracker_hidden_field').val() || null
    $.ajax
      type:        'PUT'
      url:         "/portal/admin/sub_service_requests/#{ssr_id}/add_line_item"
      data:        JSON.stringify(data)
      dataType:    'script'
      contentType: 'application/json; charset=utf-8'
      success: ->
        $().toastmessage('showSuccessToast', "Service request has been saved.")
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showErrorToast', "#{error.humanize()}.");
  )

  $(document).on('click', '#add_otf_service', ->
    ssr_id = $(this).data('sub_service_request_id')
    new_service_id = $(this).data('select_id')
    data = 
      'sub_service_request_id': ssr_id
      'new_service_id': $("##{new_service_id}").val()
      'study_tracker': $('#study_tracker_hidden_field').val() || null
    $.ajax
      type:        'PUT'
      url:         "/portal/admin/sub_service_requests/#{ssr_id}/add_otf_line_item"
      data:        JSON.stringify(data)
      dataType:    'script'
      contentType: 'application/json; charset=utf-8'
      success: (response_html) ->
        $().toastmessage('showSuccessToast', "Service request has been saved.")
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showErrorToast', "#{error.humanize()}.");
  )


  $(document).on('click', '#remove_service', ->
    object_id = $('#delete_ppv_service_id').val()
    data = {}
    data['study_tracker'] = $('#study_tracker_hidden_field').val() || null
    confirm_message = "Are you sure that you want to remove this service from all subjects' visit calendars?"
    if confirm(confirm_message)
      $.ajax
        type: 'DELETE'
        url:  "/portal/admin/line_items/#{object_id}"
        data: JSON.stringify(data)
        dataType: "script"
        contentType: 'application/json; charset=utf-8'
        success: ->
          $().toastmessage('showSuccessToast', "Service has been deleted.");
  )

  $(document).on('click', '.cwf_delete_data', ->
    klass = getObjKlass(this)
    object_id = $(this).data("#{klass}_id")
    data = {}
    data['study_tracker'] = $('#study_tracker_hidden_field').val() || null
    confirm_message = "Are you sure that you want to remove this service?"
    if confirm(confirm_message)
      $.ajax
        type: 'DELETE'
        url:  "/portal/admin/line_items/#{object_id}"
        data: JSON.stringify(data)
        dataType: "script"
        contentType: 'application/json; charset=utf-8'
        success: ->
          $().toastmessage('showSuccessToast', "Service has been deleted.");
  )

  $(document).on('click', '.expand_li', ->
    $(this).children().first().toggleClass('ui-icon-triangle-1-s')
    li_id = $(this).data('line_item_id')
    $(".li_#{li_id}").toggle()
  )

  $(document).on('click', '.add_note_link', ->
    ssr_id = $(this).data('sub_service_request_id')
    data =
      'sub_service_request_id': ssr_id
      'body': $(".note_box").val()
    $.ajax
      type: 'PUT'
      url:   "/portal/admin/sub_service_requests/#{ssr_id}/add_note"
      data:  JSON.stringify(data)
      dataType: 'script'
      contentType: 'application/json; charset=utf-8'
  )

  # SUBSIDY FUNCTIONS

  $(document).on('click', '.add_subsidy_link', ->
    data = {'subsidy': {'sub_service_request_id': $(this).data('sub_service_request_id')}}
    $.ajax
      type: 'POST'
      url:  "/portal/admin/subsidies/"
      data: JSON.stringify(data)
      dataType: "script"
      contentType: 'application/json; charset=utf-8'
      success: ->
        set_percent_subsidy()
  )

  $(document).on('change', '#subsidy_pi_contribution', ->
    pi_contribution = parseFloat($('#subsidy_pi_contribution').val()) * 100
    total = $('#direct_cost_total').data('direct_cost_total')
    subsidy = total - pi_contribution
    percent = (subsidy / total)
    validate_subsidy(pi_contribution, percent, total)
  )

  # Called when percent subsidy changes
  # Triggers a change event on the pi_contribution firing the function above
  $(document).on('change', '#subsidy_percent_subsidy', ->
    percent = parseFloat($('#subsidy_percent_subsidy').val()) / 100
    total = total = $('#direct_cost_total').data('direct_cost_total')
    subsidy = percent * total
    pi_contribution = total - subsidy
    # # No need to validate here because the validation will fire after the change event on pi_contribution
    # set_pi_contribution(pi_contribution / 100)
    # set_pi_contribution_from_percent_subsidy()
    validate_subsidy(pi_contribution, percent, total)
  )

  # $(document).on('change', '.research_billing', -> $('#subsidy_percent_subsidy').change())

  set_pi_contribution_from_percent_subsidy = ->
    percent = parseFloat($('#subsidy_percent_subsidy').val()) / 100
    total = total = $('#direct_cost_total').data('direct_cost_total')
    subsidy = percent * total
    pi_contribution = total - subsidy
    # No need to validate here because the validation will fire after the change event on pi_contribution
    set_pi_contribution(pi_contribution / 100)

  set_percent_subsidy = ->
    pi_contribution = parseFloat($('#subsidy_pi_contribution').val()) * 100
    total = $('#direct_cost_total').data('direct_cost_total')
    subsidy = total - pi_contribution
    percent = (subsidy / total)
    $('#subsidy_percent_subsidy').val(percent.toFixed(2))

  set_pi_contribution = (pi_contribution) ->
    $('#subsidy_pi_contribution').val(pi_contribution.toFixed(2)).change()

  validate_subsidy = (contribution, percent, total) ->
    validate_pi_contribution(contribution, total)
    validate_percent_subsidy(percent)

  validate_pi_contribution = (contribution, total) ->
    subsidy = total - contribution
    max_dollar_cap = parseFloat($('#direct_cost_total').data('max_dollar_cap'))
    if subsidy > max_dollar_cap
      $().toastmessage('showWarningToast', 'Value is over maximum dollar cap.')

  validate_percent_subsidy = (percent) ->
    max_percentage = parseFloat($('#direct_cost_total').data('max_percentage')) / 100
    if percent > max_percentage
      $().toastmessage('showWarningToast', 'Value is over maximum subsidy percentage.')

  
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

  $('.send_to_epic_button').on('click', ->
    ssr_id = $(this).attr('sub_service_request_id')
    $(this).button('disable')
    $.ajax
      type: 'PUT'
      url: "/portal/admin/sub_service_requests/#{ssr_id}/push_to_epic"
      contentType: 'application/json; charset=utf-8'
      success: ->
        $().toastmessage('showSuccessToast', "Project/Study has been sent to Epic")
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'application/json'
          errors = JSON.parse(jqXHR.responseText)
        else
          errors = [textStatus]
        for error in errors
          $().toastmessage('showErrorToast', "#{error.humanize()}.");
      complete: =>
        $(this).button('enable')
  )

  # INSTANTIATE HELPERS
  # set_percent_subsidy()
  $('.delete-ssr-button').button()
  $('.export_to_excel_button').button()
  $('.send_to_epic_button').button()
  $('#approval_history_table').tablesorter()
  $('#status_history_table').tablesorter()

  $(document).on('blur', '.to_zero', ->
    if $(this).val() == ''
      $(this).val(0).change()
  )

  show_return_to_portal_button = () ->
    linkHtml = "<a id='return_to_admin_portal' style='position:relative;left:700px;bottom:25px' href='/portal/admin'>Return to Admin Portal</a>"
    $("#title").append(linkHtml)
    $("#return_to_admin_portal").button()


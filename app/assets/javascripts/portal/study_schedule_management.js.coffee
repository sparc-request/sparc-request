##              **BEGIN MANAGE ARMS**                     ##

  $(document).on 'click', '#add_arm_button', ->
    data =
      "protocol_id"             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
      "schedule_tab"            : $('#current_tab').attr('value')
    $.ajax
      type: 'GET'
      url: "/portal/arms/new"
      data: data

  $(document).on 'click', '#remove_arm_button', ->
    data =
      "protocol_id"             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
      "intended_action"         : "destroy"
    $.ajax
      type: 'GET'
      url: "/portal/arms/navigate"
      data: data

  $(document).on 'click', '#remove_arm_form_button', ->
    arm_id = $("#arm_form_select").val()
    arm_name = $("#arm_form_select option:selected").text()
    data =
      "protocol_id"             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
    if confirm "Are you sure you want to remove arm: #{arm_name} from this protocol?"
      $.ajax
        type: 'DELETE'
        url: "/portal/arms/#{arm_id}"
        data: data

  $(document).on 'click', '#edit_arm_button', ->
    data =
      "protocol_id"             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
      "intended_action"         : "edit"
    $.ajax
      type: 'GET'
      url: "/portal/arms/navigate"
      data: data

  $(document).on 'change', "#arm_form_select", ->
    data =
      "protocol_id"             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
      "intended_action"         : $("#navigate_arm_form").data("intended-action")
      "arm_id"                  : $(this).val()
    $.ajax
      type: 'GET'
      url: "/portal/arms/navigate"
      data: data

##              **END MANAGE ARMS**                     ##
##          **BEGIN MANAGE VISIT GROUPS**               ##

  $(document).on 'click', '#add_visit_group_button', ->
    data =
      'study_tracker': $('#study_tracker_hidden_field').val() || null
      'current_page'            : $(".visit_dropdown").first().attr('page')
      'schedule_tab'            : $('#current_tab').attr('value')
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
    $.ajax
      type: 'GET'
      url: "/portal/visit_groups/new"
      data: data

  $(document).on 'change', '#visit_group_arm_id', ->
    arm_id = $(this).find('option:selected').val()
    data =
      'study_tracker': $('#study_tracker_hidden_field').val() || null
      'current_page'            : $("#visits_select_for_#{arm_id}").val()
      'schedule_tab'            : $('#current_tab').attr('value')
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
      'arm_id'                  : arm_id
    $.ajax
      type: 'GET'
      url: "/portal/visit_groups/new"
      data: data

  $(document).on 'click', '#edit_visit_group_button', ->
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
      'intended_action'         : "edit"
    $.ajax
      type: 'GET'
      url: "/portal/visit_groups/navigate"
      data: data

  $(document).on 'click', '#remove_visit_group_button', ->
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
      'intended_action'         : "destroy"
    $.ajax
      type: 'GET'
      url: "/portal/visit_groups/navigate"
      data: data

  $(document).on 'change', "#vg_form_arm_select", ->
    arm_id = $(this).val()
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
      "intended_action"         : $("#navigate_visit_form").data('intended-action')
      "arm_id"                  : arm_id
    $.ajax
      type: 'GET'
      url: "/portal/visit_groups/navigate"
      data: data

  $(document).on 'change', "#vg_form_select", ->
    intended_action = $("#navigate_visit_form").data('intended-action')
    if intended_action == "edit"
      data =
        'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
        "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
        "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
        "intended_action"         : intended_action
        "visit_group_id"          : $(this).val()
      $.ajax
        type: 'GET'
        url: "/portal/visit_groups/navigate"
        data: data

  $(document).on 'click', '#remove_visit_group_form_button', ->
    schedule_tab = $('#current_tab').attr('value')
    visit_group_id = $("#vg_form_select").val()
    arm_id = $('#vg_form_arm_select').val()
    page = $("#visits_select_for_#{arm_id}").val()
    data =
      'study_tracker': $('#study_tracker_hidden_field').val() || null
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
      'page'                    : page
      'schedule_tab'            : schedule_tab
    if confirm "Are you sure you want to delete the selected visit from all particpants?"
      $.ajax
        type: 'DELETE'
        url: "/portal/visit_groups/#{visit_group_id}.js"
        data: data

##          **END MANAGE VISIT GROUPS**               ##


  # $(document).on('click', '.add_visit_link', ->
  #   $('#visit-form').dialog('open')
  # )

  # $('#visit-form').dialog
  #   dialogClass: "new_visit_dialog"
  #   autoOpen: false
  #   height: 275
  #   width: 300
  #   modal: true
  #   resizable: false
  #   buttons: [
  #     {
  #       id: "submit_visit"
  #       text: "Submit"
  #       click: ->
  #         $("#visit-form").submit()
  #         $("#submit_visit").attr("disabled", true).addClass("ui-state-disabled")
  #     },
  #     {
  #       id: "cancel_visit"
  #       text: "Cancel"
  #       click: ->
  #         $(this).dialog('close')
  #     }]
  #   open: ->
  #     originalContent = $('#visit-form').html()
  #   close: ->
  #     $('#visit-form').html(originalContent)

  # $('#visit-form').submit ->
  #   sr_id = $('.add_visit_link').data('service_request_id')
  #   data =
  #     'sub_service_request_id': $('.add_visit_link').data('sub_service_request_id')
  #     'service_request_id': sr_id
  #     'visit_position': $('#visit_position').val()
  #     'arm_id': $('#arm_id').val()
  #     'study_tracker': $('#study_tracker_hidden_field').val() || null
  #     'visit_name': $('#visit_name').val()
  #     'visit_window_before': $('#visit_window_before').val()
  #     'visit_day': $('#visit_day').val()
  #     'visit_window_after': $('#visit_window_after').val()
  #   $.ajax
  #     type: 'POST'
  #     url:   "/portal/admin/service_requests/#{sr_id}/add_per_patient_per_visit_visit"
  #     data:  JSON.stringify(data)
  #     dataType: 'script'
  #     contentType: 'application/json; charset=utf-8'
  #     success: ->
  #       $().toastmessage('showSuccessToast', I18n["service_request_success"])
  #       $('#visit-form').dialog('close')
  #     error: (jqXHR, textStatus, errorThrown) ->
  #       if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
  #         errors = JSON.parse(jqXHR.responseText)
  #       else
  #         errors = [textStatus]
  #       for error in errors
  #         $().toastmessage('showErrorToast', "#{error.humanize()}.");
  #     complete: ->
  #       $("#submit_visit").attr("disabled", false).removeClass("ui-state-disabled")

  # $(document).on('click', '.delete_visit_link', ->
  #   if $(this).data('visit_count') <= 1
  #     alert(I18n["fulfillment_js"]["last_visit_delete"])
  #   else
  #     sr_id = $(this).data('service_request_id')
  #     data =
  #       'sub_service_request_id': $(this).data('sub_service_request_id')
  #       'service_request_id': sr_id
  #       'visit_position': $('#delete_visit_position').val()
  #       'arm_id': $('#arm_id').val()
  #       'study_tracker': $('#study_tracker_hidden_field').val() || null
  #     $.ajax
  #       type: 'PUT'
  #       url:   "/portal/admin/service_requests/#{sr_id}/remove_per_patient_per_visit_visit"
  #       data:  JSON.stringify(data)
  #       dataType: 'script'
  #       contentType: 'application/json; charset=utf-8'
  #       success: ->
  #         $().toastmessage('showSuccessToast', I18n["service_request_success"])

  #       error: (jqXHR, textStatus, errorThrown) ->
  #         if jqXHR.status == 500 and jqXHR.getResponseHeader('Content-Type').split(';')[0] == 'text/javascript'
  #           errors = JSON.parse(jqXHR.responseText)
  #         else
  #           errors = [textStatus]
  #         for error in errors
  #           $().toastmessage('showErrorToast', "#{error.humanize()}.");
  # )
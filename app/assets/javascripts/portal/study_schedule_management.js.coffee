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
##          **BEGIN MANAGE LINE ITEMS**               ##

  $(document).on 'click', '#add_service_button', ->
    page_hash = {}
    $(".jump_to_visit").each (index) ->
      key = $(this).attr('id').replace("jump_to_visit_", "")
      value = $(this).find("option:selected").val()
      page_hash[key] = value
    data =
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
      'page_hash'   : page_hash
      'schedule_tab': $('#current_tab').attr('value')
      'protocol_id' : $('#study_schedule_buttons').data('protocol-id')
    $.ajax
      type: 'GET'
      url: "/portal/multiple_line_items/new_line_items"
      data: data

  $(document).on 'click', '#remove_service_button', ->
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
    $.ajax
      type: 'GET'
      url: "/portal/multiple_line_items/edit_line_items"
      data: data

  $(document).on 'change', "#remove_service_id", ->
    data =
      'protocol_id' : $('#study_schedule_buttons').data('protocol-id')
      'service_id'  : $(this).find('option:selected').val()
      "sub_service_request_id"  : $('#study_schedule_buttons').data("sub-service-request-id")
      "service_request_id"      : $('#study_schedule_buttons').data("service-request-id")
    $.ajax
      type: 'GET'
      url: "/portal/multiple_line_items/edit_line_items"
      data: data

##          **END MANAGE LINE ITEMS**               ##
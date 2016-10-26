# Copyright © 2011-2016 MUSC Foundation for Research Development
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
##              **BEGIN MANAGE ARMS**                     ##

  $(document).on 'click', '#add_arm_button', ->
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
      'schedule_tab'            : $('#current_tab').attr('value')
    $.ajax
      type: 'GET'
      url: '/dashboard/arms/new'
      data: data

  ## This is keyed off of form submit, instead of button click, because chrome does stupid things.
  $(document).on 'submit', 'form#new_arm', ->
    $('form#new_arm input#add_arm_form_button').attr('disabled','disabled')

  $(document).on 'click', '#remove_arm_button', ->
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
      'intended_action'         : 'destroy'
    $.ajax
      type: 'GET'
      url: '/dashboard/arms/navigate'
      data: data

  $(document).on 'click', '#remove_arm_form_button', ->
    $(this).attr('disabled','disabled')
    arm_id = $("#arm_form_select").val()
    arm_name = $("#arm_form_select option:selected").text()
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
    if confirm "Are you sure you want to remove arm: #{arm_name} from this protocol?"
      $.ajax
        type: 'DELETE'
        url: "/dashboard/arms/#{arm_id}"
        data: data

  $(document).on 'click', '#edit_arm_button', ->
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
      'intended_action'         : 'edit'
    $.ajax
      type: 'GET'
      url: '/dashboard/arms/navigate'
      data: data

  $(document).on 'submit', 'form#edit_arm', ->
    $("#edit_arm_form_button").attr('disabled','disabled')

  $(document).on 'change', "#arm_form_select", ->
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
      'intended_action'         : $("#navigate_arm_form").data('intended-action')
      'arm_id'                  : $(this).val()
    $.ajax
      type: 'GET'
      url: '/dashboard/arms/navigate'
      data: data

##              **END MANAGE ARMS**                     ##
##          **BEGIN MANAGE VISIT GROUPS**               ##

  $(document).on 'click', '#add_visit_group_button', ->
    data =
      'study_tracker': $('#study_tracker_hidden_field').val() || null
      'current_page'            : $(".visit_dropdown").first().attr('page')
      'schedule_tab'            : $('#current_tab').attr('value')
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
    $.ajax
      type: 'GET'
      url: '/dashboard/visit_groups/new'
      data: data

  $(document).on 'change', '#visit_group_arm_id', ->
    arm_id = $(this).find('option:selected').val()
    data =
      'study_tracker': $('#study_tracker_hidden_field').val() || null
      'current_page'            : $("#visits_select_for_#{arm_id}").val()
      'schedule_tab'            : $('#current_tab').attr('value')
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
      'arm_id'                  : arm_id
    $.ajax
      type: 'GET'
      url: '/dashboard/visit_groups/new'
      data: data

  $(document).on 'click', '#edit_visit_group_button', ->
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
      'intended_action'         : 'edit'
    $.ajax
      type: 'GET'
      url: '/dashboard/visit_groups/navigate'
      data: data

  $(document).on 'click', '#remove_visit_group_button', ->
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
      'intended_action'         : 'destroy'
    $.ajax
      type: 'GET'
      url: '/dashboard/visit_groups/navigate'
      data: data

  $(document).on 'submit', 'form#edit_visit_group', ->
    $("#edit_visit_group_form_button").attr('disabled','disabled')

  $(document).on 'change', "#vg_form_arm_select", ->
    arm_id = $(this).val()
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
      'intended_action'         : $("#navigate_visit_form").data('intended-action')
      'arm_id'                  : arm_id
    $.ajax
      type: 'GET'
      url: '/dashboard/visit_groups/navigate'
      data: data

  $(document).on 'change', "#vg_form_select", ->
    intended_action = $("#navigate_visit_form").data('intended-action')
    if intended_action == 'edit'
      data =
        'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
        'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
        'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
        'intended_action'         : intended_action
        'visit_group_id'          : $(this).val()
      $.ajax
        type: 'GET'
        url: '/dashboard/visit_groups/navigate'
        data: data

  $(document).on 'submit', '#add_visit_group', ->
    $("#add_visit_group_form_button").attr('disabled','disabled')

  $(document).on 'click', '#remove_visit_group_form_button', ->
    $(this).attr('disabled','disabled')
    schedule_tab = $('#current_tab').attr('value')
    visit_group_id = $("#vg_form_select").val()
    arm_id = $('#vg_form_arm_select').val()
    page = $("#visits_select_for_#{arm_id}").val()
    data =
      'study_tracker': $('#study_tracker_hidden_field').val() || null
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
      'page'                    : page
      'schedule_tab'            : schedule_tab
    $.ajax
      type: 'DELETE'
      url: "/dashboard/visit_groups/#{visit_group_id}.js"
      data: data

##          **END MANAGE VISIT GROUPS**               ##
##          **BEGIN MANAGE LINE ITEMS**               ##

  $(document).on 'click', '#add_service_button', ->
    page_hash = {}
    $(".jump_to_visit").each (index) ->
      key = $(this).attr('id').replace('jump_to_visit_', '')
      value = $(this).find("option:selected").val()
      page_hash[key] = value
    data =
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
      'page_hash'   : page_hash
      'schedule_tab': $('#current_tab').attr('value')
      'protocol_id' : $('#study_schedule_buttons').data('protocol-id')
    $.ajax
      type: 'GET'
      url: '/dashboard/multiple_line_items/new_line_items'
      data: data

  $(document).on 'submit', 'form#new_service', ->
    $("#add_line_items_form_button").attr('disabled','disabled')

  $(document).on 'click', '#remove_service_button', ->
    line_item_count = $('#study_schedule_buttons').data('line-item-count')
    data =
      'protocol_id'             : $('#study_schedule_buttons').data('protocol-id')
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
    if line_item_count == 1
      sweetAlert("Warning", "Please add a new service(s) prior to removing the last service; To remove all services use the 'Delete Request' button.")
    else
      $.ajax
        type: 'GET'
        url: '/dashboard/multiple_line_items/edit_line_items'
        data: data

  $(document).on 'change', "#remove_service_id", ->
    data =
      'protocol_id' : $('#study_schedule_buttons').data('protocol-id')
      'service_id'  : $(this).find('option:selected').val()
      'sub_service_request_id'  : $('#study_schedule_buttons').data('sub-service-request-id')
      'service_request_id'      : $('#study_schedule_buttons').data('service-request-id')
    $.ajax
      type: 'GET'
      url: '/dashboard/multiple_line_items/edit_line_items'
      data: data

  $(document).on 'submit', '#destroy_service', ->
    $("#remove_line_items_form_button").attr('disabled','disabled')

##          **END MANAGE LINE ITEMS**               ##

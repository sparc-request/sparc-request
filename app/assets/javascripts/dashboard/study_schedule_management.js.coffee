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
##              **BEGIN MANAGE ARMS**                     ##
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

  $(document).on 'change', "#arm_select", ->
    $.ajax
      type: 'GET'
      url: '/dashboard/arms/navigate'
      data:
        ssrid: getSSRId()
        arm_id: $(this).val()
        intended_action: $('#navigateArmForm').data('intended-action')

##              **END MANAGE ARMS**                     ##
##          **BEGIN MANAGE VISIT GROUPS**               ##

  $(document).on 'change', '#visit_group_arm_id', ->
    arm_id = $(this).find('option:selected').val()
    data =
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

  $(document).on 'submit', 'form#new_service', ->
    $("#add_line_items_form_button").attr('disabled','disabled')

  $(document).on 'submit', '#destroy_service', ->
    $("#remove_line_items_form_button").attr('disabled','disabled')

##          **END MANAGE LINE ITEMS**               ##

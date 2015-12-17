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

$(document).ready ->

  $(".datetimepicker").datetimepicker(format: 'MM-DD-YYYY', allowInputToggle: true)


  $(document).on 'click', '#add_otf_service_button', ->
    data =
      "sub_service_request_id"  : $(this).data("sub_service_request_id")
      "one_time_fee"            : true
    $.ajax
      type: 'GET'
      url: "/portal/admin/line_items/new"
      data: data

  $(document).on 'click', '#add_otf_line_item_form_button', ->
    $(this).attr('disabled','disabled')

  # ADMIN APPROVALS LISTENERS BEGIN

  $(document).on 'click', '#admin_approvals_button', ->
    ssr_id = $(this).data("sub_service_request_id")
    $.ajax
      type: 'GET'
      url: "/portal/admin/sub_service_requests/#{ssr_id}/admin_approvals_show"

  $(document).on('change', '.admin_approval_checkbox', ->
    ssr_id = $(this).data("sub_service_request_id")
    data = "#{$(this).attr('name')}" : $(this).val()
    $.ajax
      type: 'POST'
      url: "/portal/admin/sub_service_requests/#{ssr_id}/admin_approvals_update"
      data: data
  )

  # ADMIN APPROVALS LISTENERS END
  # NOTES LISTENERS BEGIN

  $(document).on 'click', '#notes_index_link', ->
    data =
      'notable_type'           : "sub_service_request"
      'sub_service_request_id' : $(this).data("sub_service_request_id")
    $.ajax
      type: 'GET'
      url: "/portal/notes"
      data: data

  $(document).on 'click', '#new_note_button', ->
    data =
      'notable_type'  : $(this).data("notable-type")
      'notable_id'    : $(this).data("notable-id")
    $.ajax
      type: 'GET'
      url: "/portal/notes/new"
      data: data

  # NOTES LISTENERS END
  # SERVICE REQUEST INFO LISTENERS BEGIN

  $(document).on('change', '#sub_service_request_owner', ->
    ssr_id = $(this).data("sub_service_request_id")
    owner_id = $(this).val()
    data = "sub_service_request" : "owner_id" : owner_id
    $.ajax
      type: 'PATCH'
      url: "/portal/admin/sub_service_requests/#{ssr_id}"
      data: data
  )

  $(document).on('change', '#sub_service_request_status', ->
    ssr_id = $(this).data("sub_service_request_id")
    status = $(this).val()
    data = "sub_service_request" : "status" : status
    $.ajax
      type: 'PATCH'
      url: "/portal/admin/sub_service_requests/#{ssr_id}"
      data: data
  )

  # SERVICE REQUEST INFO LISTENERS END
  # TIMELINE LISTENERS BEGIN

  $(document).on('dp.change', '#sub_service_request_consult_arranged_date_picker', ->
    ssr_id = $(this).data("sub_service_request_id")
    consult_arranged_date = $(this).val()
    data = "sub_service_request" : "consult_arranged_date" : consult_arranged_date
    $.ajax
      type: 'PATCH'
      url: "/portal/admin/sub_service_requests/#{ssr_id}"
      data: data
  )

  $(document).on('dp.change', '#sub_service_request_requester_contacted_date_picker', ->
    ssr_id = $(this).data("sub_service_request_id")
    requester_contacted_date = $(this).val()
    data = "sub_service_request" : "requester_contacted_date" : requester_contacted_date
    $.ajax
      type: 'PATCH'
      url: "/portal/admin/sub_service_requests/#{ssr_id}"
      data: data
  )

  # TIMELINE LISTENERS END
  # SUBSIDY LISTENERS BEGIN

  $(document).on('click', '#add_subsidy_link', ->
    sub_service_request_id = $(this).data('sub_service_request_id')
    data = 'subsidy': 'sub_service_request_id': sub_service_request_id
    $.ajax
      type: 'POST'
      url:  "/portal/admin/subsidies/"
      data: data
  )

  $(document).on('change', '#subsidy_pi_contribution', ->
    subsidy_id = $(this).data("subsidy_id")
    pi_contribution = $(this).val()
    data = 'subsidy': 'pi_contribution': pi_contribution
    $.ajax
      type: 'PATCH'
      url:  "/portal/admin/subsidies/#{subsidy_id}"
      data: data
  )

  $(document).on('change', '#subsidy_percent_subsidy', ->
    subsidy_id = $(this).data("subsidy_id")
    stored_percent_subsidy = $(this).val()
    data = 'subsidy': 'stored_percent_subsidy': stored_percent_subsidy
    $.ajax
      type: 'PATCH'
      url:  "/portal/admin/subsidies/#{subsidy_id}"
      data: data
  )

  $(document).on('click', '#delete_subsidy', ->
    subsidy_id = $(this).data("subsidy_id")
    $.ajax
      type: 'DELETE'
      url: "/portal/admin/subsidys/#{subsidy_id}"
  )

  # SUBSIDY LISTENERS END


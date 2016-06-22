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

$ ->

  # Line Item Bindings

  $(document).on 'click', '.otf_details', ->
    row_index = $(this).parents('tr').data('index')
    line_item_id = $(this).parents('table.study_level_activities').bootstrapTable('getData')[row_index].id
    $.ajax
      type: 'GET'
      url: "/dashboard/line_items/#{line_item_id}/details"

  $(document).on 'click', "#otf_service_new", ->
    data =
      'sub_service_request_id'  : $(this).data('sub-service-request-id')
      'one_time_fee'            : true
    $.ajax
      type: 'GET'
      url: '/dashboard/line_items/new'
      data: data

  $(document).on 'click', '.otf_edit', ->
    row_index   = $(this).parents('tr').data('index')
    line_item_id = $(this).parents('table.study_level_activities').bootstrapTable('getData')[row_index].id
    data = 'modal' : 'study_level_activity_form'
    $.ajax
      type: 'GET'
      url: "/dashboard/line_items/#{line_item_id}/edit"
      data: data

  $(document).on 'click', '.otf_admin_rate', ->
    row_index   = $(this).parents('tr').data('index')
    line_item_id = $(this).parents('table.study_level_activities').bootstrapTable('getData')[row_index].id
    data = 'modal' : 'sla_admin_rate_form'
    $.ajax
      type: 'GET'
      url: "/dashboard/line_items/#{line_item_id}/edit"
      data: data

  $(document).on 'click', '.otf_delete', ->
    row_index   = $(this).parents('tr').data('index')
    line_item_id = $(this).parents('table.study_level_activities').bootstrapTable('getData')[row_index].id
    if confirm "Are you sure you want to delete the selected Study Level Activity from this Sub Service Request?"
      $.ajax
        type: 'DELETE'
        url: "/dashboard/line_items/#{line_item_id}"

  $(document).on 'click', '.otf_fulfillments', ->
    selected_row = $(this).parents('tr')
    fulfillments_row = $("#fulfillments_row") #already displayed
    span = $(this).children('.glyphicon')
    line_item_id = $(this).parents('table.study_level_activities').bootstrapTable('getData')[selected_row.data('index')].id
    fulfillments_already_displayed = fulfillments_row.attr('data-line_item_id') == "#{line_item_id}"

    fulfillments_row.prev('tr').first().find('.glyphicon-chevron-down').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-right').parents('.otf_fulfillments').attr('data-original-title', 'View Fulfillments')
    fulfillments_row.remove()
    unless fulfillments_already_displayed
      span.removeClass('glyphicon-chevron-right').addClass('glyphicon-refresh')
      $(this).parents('tr').after("<tr id='fulfillments_row'></tr>")
      $.ajax
        type: 'GET'
        url: '/dashboard/fulfillments'
        data: 'line_item_id' : line_item_id
    else
      $(this).attr('data-original-title', 'View Fulfillments')
      span.removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-right')

  # Fulfillment Bindings

  $(document).on 'click', '.otf_fulfillment_new', ->
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    $.ajax
      type: 'GET'
      url: '/dashboard/fulfillments/new'
      data: data

  $(document).on 'click', '.otf_fulfillment_edit', ->
    row_index   = $(this).parents('tr').data('index')
    fulfillment_id = $(this).parents("#fulfillments-table").bootstrapTable('getData')[row_index].id
    $.ajax
      type: 'GET'
      url: "/dashboard/fulfillments/#{fulfillment_id}/edit"

  $(document).on 'click', '.otf_fulfillment_delete', ->
    row_index   = $(this).parents('tr').data('index')
    fulfillment_id = $(this).parents("#fulfillments-table").bootstrapTable('getData')[row_index].id
    if confirm "Are you sure you want to delete the selected Fulfillment from this Study Level Activity?"
      $.ajax
        type: 'DELETE'
        url: "/dashboard/fulfillments/#{fulfillment_id}"

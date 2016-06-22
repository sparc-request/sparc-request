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

module Dashboard::StudyLevelActivitiesHelper

  def sla_service_name_display line_item
    if line_item.service.is_available
      line_item.service.name
    else
      line_item.service.name + ' (Disabled)'
    end
  end

  def sla_cost_display line_item
    cost = number_with_precision(Service.cents_to_dollars(line_item.direct_costs_for_one_time_fee), :precision => 2)

    return "$#{cost}"
  end

  def sla_options_buttons line_item_id
    options = raw(
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-sunglasses", aria: {hidden: "true"}))+t(:dashboard)[:study_level_activities][:actions][:details], type: 'button', class: 'btn btn-default form-control actions-button otf_details list'))
      )+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-list-alt", aria: {hidden: "true"}))+t(:dashboard)[:study_level_activities][:actions][:notes], type: 'button', class: 'btn btn-default form-control actions-button notes list', data: {notable_id: line_item_id, notable_type: "LineItem"}))
      )+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-usd", aria: {hidden: "true"}))+t(:dashboard)[:study_level_activities][:actions][:admin_rate], type: 'button', class: 'btn btn-default form-control actions-button otf_admin_rate'))
      )+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"}))+t(:dashboard)[:study_level_activities][:actions][:edit], type: 'button', class: 'btn btn-default form-control actions-button otf_edit'))
      )+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-remove", aria: {hidden: "true"}))+t(:dashboard)[:study_level_activities][:actions][:delete], type: 'button', class: 'btn btn-default form-control actions-button otf_delete'))
      )
    )

    span = raw content_tag(:span, '', class: 'glyphicon glyphicon-triangle-bottom')
    button = raw content_tag(:button, raw(span), type: 'button', class: 'btn btn-default btn-sm dropdown-toggle form-control available-actions-button', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
    ul = raw content_tag(:ul, options, class: 'dropdown-menu', role: 'menu')

    raw content_tag(:div, button + ul, class: 'btn-group overflow_webkit_button')
  end

  def sla_form_services_select form, line_item
    service = line_item.service
    if service.present? and not service.is_available
      service_name = service.name + ' (Disabled)'
      form.select "service_id", options_for_select([service_name], service_name), {include_blank: true}, class: 'form-control selectpicker', disabled: 'disabled'
    else
      service_list = line_item.sub_service_request.candidate_services.select {|x| x.one_time_fee}
      form.select "service_id", options_from_collection_for_select(service_list, 'id', 'name', line_item.service_id), {include_blank: true}, class: 'form-control selectpicker'
    end
  end

  def fulfillments_drop_button line_item_id
    content_tag(:button, class: 'btn btn-primary btn-sm otf_fulfillments list', title: "View Fulfillments", type: "button", aria: {label: "Fulfillments List"}, data: {toggle: "tooltip", animation: 'false'}) do
      content_tag(:span, '', class: "glyphicon glyphicon-chevron-right", aria: {hidden: "true"})
    end
  end

  def fulfillment_options_buttons fulfillment_id
    options = raw(
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-list-alt", aria: {hidden: "true"}))+t(:dashboard)[:fulfillments][:actions][:notes], type: 'button', class: 'btn btn-default form-control actions-button notes list', data: {notable_id: fulfillment_id, notable_type: "Fulfillment"}))
      )+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"}))+t(:dashboard)[:fulfillments][:actions][:edit], type: 'button', class: 'btn btn-default form-control actions-button otf_fulfillment_edit'))
      )+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-remove", aria: {hidden: "true"}))+t(:dashboard)[:fulfillments][:actions][:delete], type: 'button', class: 'btn btn-default form-control actions-button otf_fulfillment_delete'))
      )
    )

    span = raw content_tag(:span, '', class: 'glyphicon glyphicon-triangle-bottom')
    button = raw content_tag(:button, raw(span), type: 'button', class: 'btn btn-default btn-sm dropdown-toggle form-control available-actions-button', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
    ul = raw content_tag(:ul, options, class: 'dropdown-menu', role: 'menu')

    raw content_tag(:div, button + ul, class: 'btn-group')
  end
end

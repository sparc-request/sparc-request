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

module Dashboard::StudyLevelActivitiesHelper
  def new_sla_button(opts={})
    link_to new_dashboard_study_level_activity_path(ssrid: opts[:ssrid]), remote: true, class: 'btn btn-success', title: t('dashboard.sub_service_requests.study_level_activities.tooltips.new'), data: { toggle: 'tooltip' } do
      icon('fas', 'plus mr-2') + t('dashboard.sub_service_requests.study_level_activities.new')
    end
  end

  def sla_fulfillments_button(line_item)
    link_to icon('fas', 'list'), dashboard_fulfillments_path(line_item_id: line_item.id, ssrid: line_item.sub_service_request_id), remote: true, class: 'btn btn-primary', title: t('dashboard.sub_service_requests.study_level_activities.tooltips.fulfillments'), data: { toggle: 'tooltip' }
  end

  def sla_service_name_display(line_item)
    if line_item.service.is_available
      line_item.service.display_service_name
    else
      line_item.service.display_service_name + inactive_tag
    end
  end

  def sla_cost_display(line_item)
    currency_converter(line_item.direct_costs_for_one_time_fee)
  end

  def sla_service_rate_display(line_item)
    currency_converter(line_item.service.current_pricing_map.full_rate)
  end

  def sla_your_cost_field(line_item)
    your_cost = currency_converter(line_item.applicable_rate)
    modified  = line_item.admin_rates.present?

    link_to your_cost, edit_line_item_path(line_item, ssrid: line_item.sub_service_request_id, field: 'displayed_cost'), remote: true, class: modified ? 'text-warning' : '', title: modified ? t('calendars.tooltips.modified_rate', cost: your_cost) : '', data: { toggle: 'tooltip', html: 'true' }
  end

  def sla_actions(line_item)
    content_tag :div, class: 'd-flex justify-content-center' do
      raw [
        view_sla_button(line_item),
        edit_sla_button(line_item),
        delete_sla_button(line_item)
      ].join('')
    end
  end

  def view_sla_button(line_item)
    link_to icon('fas', 'eye'), dashboard_study_level_activity_path(line_item, ssrid: line_item.sub_service_request_id), remote: true, class: 'btn btn-info mr-1', title: t('dashboard.sub_service_requests.study_level_activities.tooltips.view'), data: { toggle: 'tooltip' }
  end

  def edit_sla_button(line_item)
    link_to icon('fas', 'edit'), edit_dashboard_study_level_activity_path(line_item, ssrid: line_item.sub_service_request_id), remote: true, class: 'btn btn-warning mr-1', title: t('actions.edit'), data: { toggle: 'tooltip' }
  end

  def delete_sla_button(line_item)
    link_to icon('fas', 'trash-alt'), dashboard_study_level_activity_path(line_item, ssrid: line_item.sub_service_request_id), remote: true, method: :delete, class: 'btn btn-danger', title: t('actions.delete'), data: { toggle: 'tooltip', confirm_swal: 'true' }
  end
end

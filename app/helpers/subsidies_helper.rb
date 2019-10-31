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

module SubsidiesHelper
  def new_subsidy_button(sub_service_request, opts={})
    url = in_dashboard? ? new_dashboard_subsidy_path(ssrid: sub_service_request.id) : new_subsidy_path(ssrid: sub_service_request.id, srid: opts[:srid])

    link_to url, remote: true, class: 'btn btn-success mr-1', title: t(:subsidies)[:tooltips][:request_subsidy], data: { toggle: 'tooltip' } do
      icon('fas', 'plus mr-2') + t('subsidies.add')
    end
  end

  def approve_subsidy_button(subsidy, opts={})
    link_to approve_dashboard_subsidy_path(subsidy), remote: true, method: :patch, class: 'btn btn-success mr-1', title: t('actions.approve'), data: { toggle: 'tooltip' } do
      icon('fas', 'check')
    end
  end

  def edit_subsidy_button(subsidy, opts={})
    url = in_dashboard? ? edit_dashboard_subsidy_path(subsidy) : edit_subsidy_path(subsidy, srid: opts[:srid])

    link_to url, remote: true, class: 'btn btn-warning mr-1 edit-subsidy' do
      icon('far', 'edit')
    end
  end

  def delete_subsidy_button(subsidy, opts={})
    url = in_dashboard? ? dashboard_subsidy_path(subsidy) : subsidy_path(subsidy, srid: opts[:srid])

    link_to url, remote: true, method: :delete, class: 'btn btn-danger delete-subsidy', data: { confirm_swal: 'true' } do
      icon('fas', 'trash-alt')
    end
  end

  def subsidy_history_action(past_subsidy)
    if past_subsidy.overridden?
      content_tag(:span, t('dashboard.sub_service_requests.history.subsidy_history.action.overridden'), class: 'text-warning')
    else
      content_tag(:span, t('dashboard.sub_service_requests.history.subsidy_history.action.deleted'), class: 'text-danger')
    end
  end
end

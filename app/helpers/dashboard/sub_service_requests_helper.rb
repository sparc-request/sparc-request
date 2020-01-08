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

module Dashboard::SubServiceRequestsHelper
  def delete_ssr_button(sub_service_request)
    content_tag :span, class: 'tooltip-wrapper', title: t('dashboard.sub_service_requests.tooltips.delete'), data: { toggle: 'tooltip' } do
      link_to dashboard_sub_service_request_path(sub_service_request), remote: true, method: :delete, class: 'btn btn-danger', data: { confirm_swal: 'true', html: t('dashboard.sub_service_requests.confirm.delete.text') } do
        icon('fas', 'trash-alt mr-2') + t('dashboard.sub_service_requests.header.delete_request')
      end
    end 
  end

  def export_ssr_button(sub_service_request)
    link_to service_request_path(srid: sub_service_request.service_request_id, ssrid: sub_service_request.id, report_type: 'request_report', admin_offset: 1, format: :xlsx), class: 'btn btn-secondary', title: t('dashboard.sub_service_requests.tooltips.export'), data: { toggle: 'tooltip' } do
      icon('fas', 'download mr-2') + t('actions.export')
    end
  end

  def push_to_epic_ssr_button(sub_service_request, request_valid)
    content_tag :button, class: ['btn btn-primary', request_valid ? '' : 'disabled'], id: 'pushToEpic', title: request_valid ? t('dashboard.sub_service_requests.tooltips.push_to_epic') : '', data: { toggle: 'tooltip' } do
      icon('fas', 'sync mr-2') + t('dashboard.sub_service_requests.header.epic.push')
    end
  end

  def ready_for_fulfillment_display(sub_service_request, request_valid)
    if sub_service_request.ready_for_fulfillment?
      if sub_service_request.in_work_fulfillment?
        if current_user.go_to_cwf_rights?(sub_service_request.organization)
          if sub_service_request.imported_to_fulfillment?
            # In fulfillment, and user has rights to view in Fulfillment
            link_to "#{Setting.get_value("clinical_work_fulfillment_url")}/sub_service_request/#{sub_service_request.id}", target: :_blank, id: 'fulfillmentStatus', class: 'btn btn-success', data: { imported: sub_service_request.imported_to_fulfillment? } do
              icon('fas', 'eye mr-2') + t('dashboard.sub_service_requests.header.fulfillment.go_to_fulfillment')
            end
          else
            # Pending button displayed until ssr is imported to fulfillment
            content_tag(:button, id: 'fulfillmentStatus', class: 'btn btn-secondary disabled', data: { imported: sub_service_request.imported_to_fulfillment? }) do
              icon('fas', 'sync mr-2 rotate') + t('dashboard.sub_service_requests.header.fulfillment.pending')
            end
          end
        else
          # In fulfillment, but user has no rights to view in Fulfillment
          content_tag :div, t('dashboard.sub_service_requests.header.fulfillment.in_fulfillment'), id: 'fulfillmentStatus', class: 'alert alert-sm alert-success mb-0'
        end
      elsif current_user.send_to_cwf_rights?(sub_service_request.organization)
        # Not in Fulfillment, and user has rights to send to Fulfillment
        content_tag :button, id: 'pushToFulfillment', class: ['btn btn-primary', request_valid ? '' : 'disabled'] do
          icon('fas', 'sync mr-2') + t('dashboard.sub_service_requests.header.fulfillment.send_to_fulfillment')
        end
      else
        # Not in Fulfillment, but user has no rights to send to Fulfillment
        content_tag :button, id: 'pushToFulfillment', class: 'btn btn-primary disabled' do
          icon('fas', 'sync mr-2') + t('dashboard.sub_service_requests.header.fulfillment.send_to_fulfillment')
        end
      end
    else
      # Not ready for Fulfillment
      t('dashboard.sub_service_requests.header.fulfillment.not_enabled')
    end
  end

  def resend_surveys_ssr_button(sub_service_request)
    if sub_service_request.surveys_completed?
      content_tag :div, t('dashboard.sub_service_requests.header.surveys.completed'), class: 'alert alert-sm alert-success mb-0'
    else
      link_to resend_surveys_dashboard_sub_service_request_path(sub_service_request), remote: true, method: :put, class: 'btn btn-warning', id: "resendSurveys", onclick: "$(this).addClass('disabled')", title: t('dashboard.sub_service_requests.header.surveys.last_sent', date: format_date(sub_service_request.survey_latest_sent_date, html: true)), data: { toggle: 'tooltip', html: 'true' } do
        icon('fas', 'clipboard-list mr-2') + t('dashboard.sub_service_requests.header.surveys.resend')
      end
    end
  end

  def display_line_items_otf(lis)
    # only show the services that are set to be pushed to Epic when use_epic = true
    if Setting.get_value('use_epic')
      lis.select{ |li| li.service.cpt_code.present? }
    else
      lis
    end
  end

  def ssr_status_dropdown_button(ssr)
    if ssr.is_complete?
      klass = 'border-success text-success'
    elsif ssr.is_locked?
      klass = 'border-danger text-danger'
    else
      klass = ''
    end

    content_tag :button, class: ['btn btn-block btn-light dropdown-toggle', klass, ssr.previously_submitted? ? '' : 'disabled'], id: 'requestStatus', role: 'button', data: { toggle: 'dropdown', flip: 'false', boundary: 'window' }, aria: { haspopup: 'true', expanded: 'false' } do
      if ssr.is_complete?
        icon('fas', 'check mr-2')
      elsif ssr.is_locked?
        icon('fas', 'lock mr-2')
      else
        ''
      end + PermissibleValue.get_value('status', ssr.status)
    end
  end

  def ssr_status_dropdown_statuses(ssr)
    available_statuses = ssr.organization.available_statuses.selected.pluck(:status)

    statuses = 
      if ssr.is_complete?
        PermissibleValue.get_inverted_hash('status').sort.select{ |_, status| Status.complete?(status) }
      else
        PermissibleValue.get_inverted_hash('status').sort
      end.select{ |_, status| available_statuses.include?(status) }

    raw(statuses.map do |label, status|
      if !ssr.organization.has_editable_status?(status)
        content_tag :span, class: 'tooltip-wrapper', title: t('dashboard.sub_service_requests.tooltips.locked_status'), data: { toggle: 'tooltip' } do
          link_to dashboard_sub_service_request_path(ssr, sub_service_request: { status: status }), remote: true, method: :put, class: ['dropdown-item alert-danger', status == ssr.status ? 'active' : ''] do
            icon('fas', 'lock mr-2') + label
          end
        end
      elsif Status.complete?(status)
        content_tag :span, class: 'tooltip-wrapper', title: t('dashboard.sub_service_requests.tooltips.finished_status'), data: { toggle: 'tooltip' } do
          link_to dashboard_sub_service_request_path(ssr, sub_service_request: { status: status }), remote: true, method: :put, class: ['dropdown-item alert-success', status == ssr.status ? 'active' : ''], data: { confirm_swal: ssr.is_complete? ? 'false' : 'true', html: t('dashboard.sub_service_requests.confirm.finished_status.text', status: label) } do
            icon('fas', 'check mr-2') + label
          end
        end
      else
        link_to dashboard_sub_service_request_path(ssr, sub_service_request: { status: status }), remote: true, method: :put, class: ['dropdown-item', status == ssr.status ? 'active' : ''] do
          content_tag :span, label, class: 'ml-3 pl-2'
        end
      end
    end.join(''))
  end

  def user_display_protocol_total protocol, service_request
    return (protocol.grand_total(service_request) / 100.0)
  end

  def effective_current_total sub_service_request
    sub_service_request.set_effective_date_for_cost_calculations
    total = (sub_service_request.direct_cost_total / 100.0)
    sub_service_request.unset_effective_date_for_cost_calculations

    return total
  end

  def ssr_actions(ssr, admin_orgs)
    admin_access = (admin_orgs & ssr.org_tree).any?

    content_tag :div, class: 'd-flex justify-content-center' do
      raw([
        notify_ssr_button(ssr),
        view_ssr_button(ssr),
        admin_edit_ssr_buttton(ssr, admin_access)
      ].join(''))
    end
  end

  def notify_ssr_button(ssr)
    render 'dashboard/notifications/dropdown.html', sub_service_request: ssr
  end

  def view_ssr_button(ssr)
    link_to icon('fas', 'eye'), dashboard_sub_service_request_path(ssr), remote: true, title: t('dashboard.service_requests.tooltips.view'), class: 'btn btn-info mx-1 view-request', data: { toggle: 'tooltip', boundary: 'window' }
  end

  def admin_edit_ssr_buttton(ssr, admin_access)
    if admin_access
      link_to icon('fas', 'edit'), dashboard_sub_service_request_path(ssr), title: t('dashboard.service_requests.tooltips.admin_edit'), class: "btn btn-warning edit-request", data: { toggle: 'tooltip', boundary: 'window' }
    end
  end
end


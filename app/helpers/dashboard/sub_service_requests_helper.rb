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

module Dashboard::SubServiceRequestsHelper

  def ssr_statuses
    arr = {}
    @service_requests.map do |s|
      ssr_status = pretty_tag(s.status).blank? ? "draft" : pretty_tag(s.status)
      if arr[ssr_status].blank?
        arr[ssr_status] = [s]
      else
        arr[ssr_status] << s
      end
    end
    arr
  end

  def full_ssr_id(ssr)
    protocol = ssr.protocol
    if protocol
      "#{protocol.id}-#{ssr.ssr_id}"
    else
      "-#{ssr.ssr_id}"
    end
  end

  def service_request_owner_display sub_service_request
    if sub_service_request.status == "draft"
      content_tag(:span, 'Not available in draft status.')
    else
      select_tag "sub_service_request_owner", owners_for_select(sub_service_request), :prompt => t(:constants)[:prompts][:select], :'data-sub_service_request_id' => sub_service_request.id, :class => 'selectpicker'
    end
  end

  def ready_for_fulfillment_display user, sub_service_request
    display = content_tag(:div, "", class: "row")
    if sub_service_request.ready_for_fulfillment?
      if sub_service_request.in_work_fulfillment?
        if user.clinical_provider_rights?
          # In fulfillment and user has rights
          display += link_to t(:dashboard)[:sub_service_requests][:header][:fulfillment][:go_to_fulfillment], CLINICAL_WORK_FULFILLMENT_URL, target: "_blank", class: "btn btn-primary btn-md"
        else
          # In fulfillment, user does not have rights, disable button
          display += link_to t(:dashboard)[:sub_service_requests][:header][:fulfillment][:in_fulfillment], CLINICAL_WORK_FULFILLMENT_URL, target: "_blank", class: "btn btn-primary btn-md", disabled: true
        end
      else
        # Not in Fulfillment
        display += button_tag t(:dashboard)[:sub_service_requests][:header][:fulfillment][:send_to_fulfillment], data: { sub_service_request_id: sub_service_request.id }, id: "send_to_fulfillment_button", class: "btn btn-success btn-md form-control"
      end
    else
      # Not ready for Fulfillment
      display += content_tag(:span, t(:dashboard)[:sub_service_requests][:header][:fulfillment][:not_enabled])
    end

    return display
  end

  def candidate_service_options(services, include_cpt=false)
    services.map do |service|
      n = include_cpt ? service.display_service_name : service.name
      [n, service.id]
    end
  end

  def per_patient_line_items(line_items)
    line_items.map { |line_item| [line_item.service.name, line_item.id]}
  end

  def calculate_total
    if @sub_service_request
      total = @sub_service_request.direct_cost_total / 100.0
    end

    total
  end

  def user_display_total sub_service_request
    return (sub_service_request.direct_cost_total / 100.0)
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

  def subsidy_user_display_total sub_service_request, subsidy
    pi_contribution = (subsidy.pi_contribution / 100.0)

    return user_display_total(sub_service_request) - pi_contribution
  end

  def subsidy_effective_current_total sub_service_request, subsidy
    pi_contribution = (subsidy.pi_contribution / 100.0)

    return effective_current_total(sub_service_request) - pi_contribution
  end

  #This is used to filter out ssr's on the cfw home page
  #so that clinical providers can only see ones that are
  #under their core.  Super users and clinical providers on the
  #ctrc can see all ssr's.
  def user_can_view_ssr?(study_tracker, ssr, user)
    can_view = false
    if user.is_super_user? || user.clinical_provider_for_ctrc? || (user.is_service_provider?(ssr) && (study_tracker == false))
      can_view = true
    else
      ssr.line_items.each do |line_item|
        clinical_provider_cores(user).each do |core|
          if line_item.core == core
            can_view = true
          end
        end
      end
    end
    can_view
  end

  def clinical_provider_cores(user)
    cores = []
    user.clinical_providers.each do |provider|
      cores << provider.core
    end

    cores
  end

  def full_user_name_from_id id
    user = Identity.find(id)

    user.display_name
  end

  def extract_subsidy_audit_data object, convert_to_dollars=false
    if object
      display = []
      if object.kind_of?(Array) && !object.empty?
        object.each do |element|
          if convert_to_dollars
            display << (element.to_f / 100)
          else
            display << element
          end
        end
        return (display[0] ? display[0].to_s : "0") + " => " + (display[1] ? display[1].to_s : "0")
      else
        return convert_to_dollars ? (object.to_f / 100) : object
      end
    end
  end

  def calculate_effective_current_total
    if @sub_service_request
      @sub_service_request.set_effective_date_for_cost_calculations
      total = @sub_service_request.direct_cost_total / 100
      @sub_service_request.unset_effective_date_for_cost_calculations
    end

    total
  end

  def calculate_user_display_total
    if @sub_service_request
      total = @sub_service_request.direct_cost_total / 100
    end

    total
  end

  def ssr_notifications_display(ssr, user)
    render 'dashboard/notifications/dropdown.html', sub_service_request: ssr, user: user
  end

  def ssr_actions_display(ssr, user, permission_to_edit, admin_orgs, show_view_ssr_back)
    admin_access = (admin_orgs & ssr.org_tree).any?

    ssr_view_button(ssr, show_view_ssr_back)+
    ssr_edit_button(ssr, user, permission_to_edit)+
    ssr_admin_button(ssr, user, permission_to_edit, admin_access)
  end

  def display_owner(ssr)
    ssr.owner.full_name if ssr.owner_id.present?
  end

  def display_ssr_submissions(ssr)
    line_items = ssr.line_items.includes(service: :questionnaires).includes(:submission).to_a.select(&:has_incomplete_additional_details?)

    if line_items.any?
      protocol    = ssr.protocol
      submissions = ""

      line_items.each do |li|
        submissions +=  content_tag(
                          :option,
                          "#{li.service.name}",
                          data: {
                            service_id: li.service.id,
                            protocol_id: protocol.id,
                            line_item_id: li.id
                          }
                        )
      end

      content_tag(
        :select,
        submissions.html_safe,
        title: t(:dashboard)[:service_requests][:additional_details][:selectpicker],
        class: 'selectpicker complete-details',
        data: {
          style: 'btn-danger',
          counter: 'true'
        }
      )
    else
      ''
    end
  end

  private

  def ssr_view_button(ssr, show_view_ssr_back)
    content_tag(:button, t(:dashboard)[:service_requests][:actions][:view], class: 'view-service-request btn btn-primary btn-sm', type: 'button', data: { sub_service_request_id: ssr.id, show_view_ssr_back: show_view_ssr_back.to_s })
  end

  def ssr_edit_button(ssr, user, permission_to_edit)
    # The SSR must not be locked, and the user must either be an authorized user or an authorized admin
    if ssr.can_be_edited? && permission_to_edit
      content_tag(:button, t(:dashboard)[:service_requests][:actions][:edit], class: 'edit-service-request btn btn-warning btn-sm', type: 'button', data: { permission: permission_to_edit.to_s, url: "/service_requests/#{ssr.service_request.id}/catalog?sub_service_request_id=#{ssr.id}"})
    else
      ''
    end
  end

  def ssr_admin_button(ssr, user, permission_to_edit, admin_access)
    if admin_access
      content_tag(:button, t(:dashboard)[:service_requests][:actions][:admin_edit], class: "edit-service-request btn btn-warning btn-sm", type: 'button', data: { permission: admin_access.to_s, url: "/dashboard/sub_service_requests/#{ssr.id}" })
    else
      ''
    end
  end

  def ssr_select_options(ssr)
    ssr.nil? ? [] : statuses_with_classes(ssr)
  end

  private

  def statuses_with_classes(ssr)
    ssr.organization.get_available_statuses.invert.map do |status|
      if status.include?('Complete') || status.include?('Withdrawn')
        status.push(:class=> 'finished-status')
      else
        status
      end
    end
  end
end


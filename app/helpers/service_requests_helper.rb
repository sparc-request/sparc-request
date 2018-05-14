# Copyright © 2011-2018 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module ServiceRequestsHelper

  def protocol_id_display(sub_service_request, service_request)
    if sub_service_request && sub_service_request.protocol.present?
      " (SRID: #{sub_service_request.protocol.id})"
    elsif service_request && service_request.protocol.present?
      " (SRID: #{service_request.protocol.id})"
    else
      ""
    end
  end

  def current_organizations(service_request, sub_service_request)
    organizations = {}

    if sub_service_request.present?
      organizations[sub_service_request.organization_id] = sub_service_request.organization.name
    else
      service_request.sub_service_requests.each do |ssr|
        organizations[ssr.organization_id] = ssr.organization.name
      end
    end

   organizations
  end

  def organization_name_display(organization, locked)
    header  = content_tag(:span, organization.name)
    header += content_tag(:span, '', class: 'glyphicon glyphicon-lock locked') if locked

    header
  end

  def organization_description_display(organization)
    organization.description.present? ? raw(organization.description) : t(:proper)[:catalog][:no_description]
  end

  def ssr_name_display(sub_service_request)
    header  = content_tag(:span, sub_service_request.organization.name + (sub_service_request.ssr_id ? " (#{sub_service_request.ssr_id})" : ""))
    header += content_tag(:span, '', class: 'glyphicon glyphicon-lock locked') if !sub_service_request.can_be_edited?

    header
  end

  def service_name_display(line_item)
    ssr = line_item.sub_service_request
    service = line_item.service
    display_name = service.display_service_name + (ssr.ssr_id ? " (#{ssr.ssr_id})" : "")

    if ssr.can_be_edited?
      link_to(display_name, "javascript:void(0)", class: "service service-#{service.id} btn btn-default", data: { id: service.id })
    else
      link_to "<i class='glyphicon glyphicon-lock text-danger'></i> #{display_name}".html_safe, "javascript:void(0)", class: "text-danger list-group-item-danger service service-#{service.id} btn btn-default list-group-item", data: { id: service.id }
    end
  end

  # RIGHT NAVIGATION BUTTONS
  def faq_helper
    if Setting.get_value("use_faq_link")
      link_to t(:proper)[:right_navigation][:faqs][:header], Setting.get_value("faq_url"), target: :blank, class: 'btn btn-primary btn-lg btn-block help-faq-button no-margin-x'
    else
      link_to t(:proper)[:right_navigation][:faqs][:header], get_help_service_request_path, remote: true, class: 'btn btn-primary btn-lg btn-block help-faq-button no-margin-x'
    end
  end

  def feedback_helper
    if Setting.get_value("use_feedback_link")
      link_to t(:proper)[:right_navigation][:feedback][:header], Setting.get_value("feedback_link"), target: :blank, class: 'feedback-button btn btn-primary btn-lg btn-block no-margin-x'
    else
      content_tag(:button, t(:proper)[:right_navigation][:feedback][:header], class: 'feedback-button btn btn-primary btn-lg btn-block no-margin-x')
    end
  end

  def save_as_draft_button(sub_service_request_id=nil)
    link_to t(:proper)[:navigation][:bottom][:save_as_draft],
      save_and_exit_service_request_path(sub_service_request_id: sub_service_request_id),
      remote: true, class: 'btn btn-default'
  end

  def step_nav_button(text, color, url, inactive_link)
    if inactive_link
      content_tag(:div,
        content_tag(:div, raw(text), class: "btn step-text")+
        content_tag(:div, '', class: "right-arrow"),
        class: "step-btn step-btn-#{color} disabled_steps"
      )
    else
      link_to(
        content_tag(:div, raw(text), class: "btn step-text")+
        content_tag(:div, '', class: "right-arrow"),
        url,
        class: "step-btn step-btn-#{color}"
      )
    end
  end

  def display_ssr_id(sub_service_request)
    if sub_service_request
      sub_service_request.protocol_id.to_s + '-' + sub_service_request.ssr_id
    end
  end
end

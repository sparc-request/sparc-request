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

module ApplicationHelper

  def show_welcome_message(current_user, bootstrap = false)
    returning_html = ""
    if current_user
      logged_in_as = current_user.email ? current_user.email : current_user.full_name
      returning_html +=
        content_tag(:span,
          t(:dashboard)[:navbar][:logged_in_as] +
          logged_in_as + " ") +
        link_to('Logout', destroy_identity_session_path, method: :delete, class: bootstrap ? "btn btn-warning" : "")
    else
      # could be used to provide a login link
      returning_html += content_tag(:span, "Not Logged In")
    end

    raw(returning_html)
  end

  def format_date(date)
    date.try(:strftime, '%D') || ""
  end

  def css_class(organization)
    case organization.type
    when 'Institution'
      organization.css_class.empty? ? 'light-blue-provider' : organization.css_class
    when 'Provider'
      organization.css_class.empty? ? 'light-blue-provider' : organization.css_class
    when 'Program'
      css_class(organization.provider)
    when 'Core'
      css_class(organization.program)
    end
  end

  def ssr_program_core organization
    case organization.type
    when 'Core'
      "#{organization.parent.abbreviation}/#{organization.abbreviation}"
    when 'Program'
      organization.abbreviation
    else
      nil
    end
  end

  def ssr_provider organization
    case organization.type
    when 'Core'
      organization.parent.parent.abbreviation
    when 'Program'
      organization.parent.abbreviation
    when 'Provider'
      organization.abbreviation
    else
      nil
    end
  end

  def ssr_institution organization
    case organization.type
    when 'Core'
      organization.parent.parent.parent.abbreviation
    when 'Program'
      organization.parent.parent.abbreviation
    when 'Provider'
      organization.parent.abbreviation
    when 'Institution'
      organization.abbreviation
    else
      nil
    end
  end

  def ssr_primary_contacts organization
    sps = organization.service_providers_lookup
    sps.map{|x| x.is_primary_contact? ? x.identity.display_name : nil}.compact.join("<br />")
  end

  # devise helpers
  def resource_name
    :identity
  end

  def resource
    @resource ||= Identity.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:identity]
  end

  def resource_class
    devise_mapping.to
  end

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def entity_visibility_class entity
    entity.is_available == false ? 'entity_visibility' : ''
  end

  def display_protocol_id(service_request)
    if service_request.protocol
      return service_request.protocol.id
    else
      return ""
    end
  end

  def inactive_tag
    content_tag(:span, t(:calendars)[:inactive], class: 'inactive-text')
  end

  ##Sets css bootstrap classes for rails flash message types##
  def twitterized_type type
    case type.to_sym
      when :alert
        "alert-danger"
      when :error
        "alert-danger"
      when :notice
        "alert-info"
      when :success
        "alert-success"
      else
        type.to_s
    end
  end

  def navbar_link(identifier, details, highlighted_link)
    name, path = details
    highlighted = identifier == highlighted_link

    accessible = false

    if current_user
      accessible = case identifier
      when 'sparc_fulfillment'
        current_user.clinical_providers.any? || current_user.is_super_user?
      when 'sparc_catalog'
        current_user.catalog_managers.any?
      when 'sparc_report'
        current_user.is_super_user?
      when 'sparc_funding'
        current_user.is_funding_admin?
      when 'sparc_forms'
        current_user.is_site_admin? || current_user.is_super_user? || current_user.is_service_provider?
      else
        true
      end
    else ## show base module when logged out
      accessible = true if ['sparc_dashboard', 'sparc_request', 'sparc_info'].include? identifier
    end

    render_navbar_link(name, path, highlighted) if accessible
  end

  def render_navbar_link(name, path, highlighted)
    content_tag(:li, link_to(name.to_s, path, target: '_blank', class: highlighted ? 'highlighted' : ''), class: 'dashboard nav-bar-link')
  end

  def calculate_step_params(service_request)
    has_subsidy           = service_request.sub_service_requests.any?(&:has_subsidy?)
    eligible_for_subsidy  = service_request.sub_service_requests.any?(&:eligible_for_subsidy?)
    subsidy               = has_subsidy || eligible_for_subsidy
    classes               = subsidy ? 'step-with-subsidy' : 'step-no-subsidy'

    return subsidy, classes
  end
end

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
  def format_date(date, opts={})
    if date.present?
      if opts[:html]
        content_tag :span do
          raw date.strftime('%m/%d/%Y')
        end
      else
        date.strftime('%m/%d/%Y')
      end
    end
  end

  def format_datetime(datetime, opts={})
    if datetime.present?
      if opts[:html]
        content_tag :span do
          raw datetime.strftime('%m/%d/%Y %l:%M') + content_tag(:span, datetime.strftime(':%S'), class: 'd-none') + datetime.strftime(' %p')
        end
      else
        datetime.strftime('%m/%d/%Y %l:%M')
      end
    end
  end

  def format_phone(phone)
    if phone.present?
      phone.gsub!(/[^0-9#]/, '')

      formatted = ""
      begin
        formatted += "(#{phone.first(3)})"
        formatted += " #{phone.from(3).to(2)}"
        formatted += "-#{phone.from(6).to(3)}"
        formatted += phone.from(10).gsub('#', " #{I18n.t('constants.phone.extension')} ") if phone.include?('#')
      rescue
      end

      return formatted
    else
      return phone
    end
  end

  def format_currency(amount)
    "%.2f" % amount rescue ""
  end

  def format_count(value, digits=1)
    if value >= 10.pow(digits)
      "#{value - (value - (10.pow(digits) - 1))}+"
    else
      value
    end
  end

  def css_class(organization)
    case organization.type
    when 'Institution'
      organization.css_class.blank? ? 'light-blue-provider' : organization.css_class
    when 'Provider'
      organization.css_class.blank? ? 'light-blue-provider' : organization.css_class
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
    content_tag(:small, class: 'text-danger ml-1') do
      content_tag(:em, t('calendars.inactive'))
    end
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
    active = identifier == highlighted_link

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
      accessible = true if ['sparc_dashboard', 'sparc_request', 'sparc_info'].include?(identifier)
    end

    if accessible
      content_tag :li, class: 'nav-item' do
        link_to name, path, target: :_blank, class: ['nav-link', active ? 'active' : '']
      end
    end
  end

  def in_dashboard?
    ##Rescue because request.referrer can be unrecognizable. If it's not recognizable by rails, it also can't be a dashboard path.
    dashboard_path = Rails.application.routes.recognize_path(request.referrer)[:controller].starts_with?('dashboard/') rescue false

    @in_dashboard ||= (request.format.html? && request.path.start_with?('/dashboard')) || dashboard_path
  end

  def in_admin?
    @in_admin ||= in_dashboard? && (params[:ssrid].present? || (controller_name == 'sub_service_requests' && !['index', 'show'].include?(action_name)) || (controller_name == 'sub_service_requests' && action_name == 'show' && request.format.html?))
  end

  def in_review?
    @in_review ||= action_name == 'review' || (request_referrer_action == 'review' && !request.format.html?)
  end

  def request_referrer_action
    Rails.application.routes.recognize_path(request.referrer)[:action] rescue nil
  end

  def request_referrer_controller
    Rails.application.routes.recognize_path(request.referrer)[:controller] rescue nil
  end
end

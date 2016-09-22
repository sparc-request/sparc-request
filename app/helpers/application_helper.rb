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

module ApplicationHelper
  def show_welcome_message current_user, bootstrap = false
    returning_html = ""
    if current_user
      returning_html += content_tag(:span, t(:dashboard)[:navbar][:logged_in_as] + current_user.email + " ") + link_to('Logout', destroy_identity_session_path, method: :delete, class: bootstrap ? "btn btn-warning" : "")
    else
      # could be used to provide a login link
      returning_html += content_tag(:span, "Not Logged In")
    end

    raw(returning_html)
  end

  def protocol_id_display(sub_service_request, service_request)
    if sub_service_request && sub_service_request.service_request.protocol.present?
      "SRID: #{sub_service_request.service_request.protocol.id}"
    elsif service_request && service_request.protocol.present?
      "SRID: #{service_request.protocol.id}"
    else
      ""
    end
  end

  def css_class(organization)
    case organization.type
    when 'Institution'
      organization.css_class
    when 'Provider'
      organization.css_class
    when 'Program'
      css_class(organization.provider)
    when 'Core'
      css_class(organization.program)
    end
  end

  def controller_action
    params[:controller] + '/' + params[:action]
  end

  def line_item_visit_input(arm, line_item, visit, tab, totals_hash={}, unit_minimum=0, portal=nil, locked=false)
    base_url = "/service_requests/#{line_item.service_request_id}/service_calendars?visit=#{visit.id}"
    case tab
    when 'template'
      if locked
        ""
      else
        content_tag(:div,
          check_box_tag("visits_#{visit.id}", 1, (visit.research_billing_qty.to_i > 0 or visit.insurance_billing_qty.to_i > 0 or visit.effort_billing_qty.to_i > 0), class: "line_item_visit_template visits_#{visit.id}", :'data-arm_id' => arm.id, update: "#{base_url}&tab=template&portal=#{portal}"),
          class: 'full-centered'
        )
      end
    when 'quantity'
      content_tag(:div, (visit.research_billing_qty.to_i + visit.insurance_billing_qty.to_i + visit.effort_billing_qty.to_i), {class: "line_item_visit_quantity full-centered"})
    when 'billing_strategy'
      if locked
        raw(
          content_tag(:span, visit.research_billing_qty, class: 'locked-billing-type')+
          content_tag(:span, visit.insurance_billing_qty, class: 'locked-billing-type')+
          content_tag(:span, visit.effort_billing_qty, class: 'locked-billing-type')
        )
      else
        raw(
          text_field_tag("visits_#{visit.id}_research_billing_qty",
            visit.research_billing_qty,
            current_quantity: visit.research_billing_qty,
            previous_quantity: visit.research_billing_qty,
            data: { unit_minimum: unit_minimum, arm_id: arm.id },
            class: "line_item_visit_research_billing_qty line_item_visit_billing visits_#{visit.id}",
            update: "#{base_url}&tab=billing_strategy&column=research_billing_qty&portal=#{portal}",
          )+
          text_field_tag("visits_#{visit.id}_insurance_billing_qty",
            visit.insurance_billing_qty,
            current_quantity: visit.insurance_billing_qty,
            previous_quantity: visit.insurance_billing_qty,
            data: { unit_minimum: unit_minimum, arm_id: arm.id },
            class: "line_item_visit_billing visits_#{visit.id}",
            update: "#{base_url}&tab=billing_strategy&column=insurance_billing_qty&portal=#{portal}",
          )+
          text_field_tag("visits_#{visit.id}_effort_billing_qty",
            visit.effort_billing_qty,
            current_quantity: visit.effort_billing_qty,
            previous_quantity: visit.effort_billing_qty,
            data: { unit_minimum: unit_minimum, arm_id: arm.id },
            class: "line_item_visit_billing visits_#{visit.id}",
            update: "#{base_url}&tab=billing_strategy&column=effort_billing_qty&portal=#{portal}",
          )
        )
      end
    when 'calendar'
      label_tag nil, qty_cost_label(visit.research_billing_qty + visit.insurance_billing_qty, currency_converter(totals_hash["#{visit.id}"])), class: "line_item_visit_pricing"
    end
  end

  def qty_cost_label qty, cost
    return nil if qty == 0
    cost = cost || "$0.00"
    "#{qty} - #{cost}"
  end

  def generate_visit_header_row arm, service_request, page, sub_service_request, portal=nil
    base_url = "/service_requests/#{service_request.id}/service_calendars"
    day_url = base_url + "/set_day"
    window_before_url = base_url + "/set_window_before"
    window_after_url = base_url + "/set_window_after"
    page = page == 0 ? 1 : page
    beginning_visit = (page * 5) - 4
    ending_visit = (page * 5) > arm.visit_count ? arm.visit_count : (page * 5)
    returning_html = ""
    line_items_visits = arm.line_items_visits
    visit_groups = arm.visit_groups

    (beginning_visit .. ending_visit).each do |n|
      visit_name = visit_groups[n - 1].name || "Visit #{n}"
      visit_group = visit_groups[n - 1]

      if params[:action] == 'review' || params[:action] == 'show' || params[:action] == 'refresh_service_calendar'
        returning_html += content_tag(:th, content_tag(:span, visit_name), width: 60, class: 'visit_number')
      elsif @merged
        returning_html += content_tag(:th,
                            ((USE_EPIC) ?
                            label_tag('decrement',t(:calendar_page)[:headers][:decrement], class: 'decrement_days') +
                            label_tag('day',t(:calendar_page)[:headers][:day]) +
                            label_tag('increment', t(:calendar_page)[:headers][:increment], class: 'increment_days') +
                            tag(:br) +
                            content_tag(:span, visit_group.window_before, style: "display:inline-block;width:25px;") +
                            content_tag(:span, visit_group.day, style: "display:inline-block;width:25px;") +
                            content_tag(:span, visit_group.window_after, style: "display:inline-block;width:25px;") +
                            tag(:br) : label_tag("")) +
                            content_tag(:span, visit_name, style: "display:inline-block;width:75px;word-wrap:break-word;") +
                            tag(:br))
      elsif @tab != 'template'
        returning_html += content_tag(:th,
                                      ((USE_EPIC) ?
                                      label_tag('decrement',t(:calendar_page)[:headers][:decrement], class: 'decrement_days') +
                                      label_tag('day',t(:calendar_page)[:headers][:day]) +
                                      label_tag('increment', t(:calendar_page)[:headers][:increment], class: 'increment_days') +
                                      tag(:br) +
                                      text_field_tag("window_before", visit_group.window_before, class: "visit_window visit_window_before position_#{n} input_small", size: 1, :'data-position' => n - 1, :'data-window-before' => visit_group.window_before, update: "#{window_before_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                      text_field_tag("day", visit_group.day, class: "visit_day position_#{n}", maxlength: 4, size: 4, :'data-position' => n - 1, :'data-day' => visit_group.day, update: "#{day_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                      text_field_tag("window_after", visit_group.window_after, class: "visit_window visit_window_after position_#{n} input_small", size: 1, :'data-position' => n - 1, :'data-window-after' => visit_group.window_after, update: "#{window_after_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                      tag(:br)
                                      : label_tag('')) +
                                      text_field_tag("arm_#{arm.id}_visit_name_#{n}", visit_name, class: "visit_name", size: 10, :'data-arm_id' => arm.id, :'data-visit_position' => n - 1, :'data-service_request_id' => service_request.id) +
                                      tag(:br))
      else
        if sub_service_request
          filtered_line_items_visits = line_items_visits.select{|x| x.line_item.sub_service_request_id == sub_service_request.id }
        else
          filtered_line_items_visits = line_items_visits.select{|x| x.line_item.service_request_id == service_request.id }.reject { |liv| !liv.line_item.sub_service_request.can_be_edited? }
        end

        checked = filtered_line_items_visits.each.map{|liv| liv.visits[n.to_i-1].research_billing_qty >= 1}.all?
        action = checked == true ? 'uncheck' : 'check'
        icon = checked == true ? 'ui-icon-close' : 'ui-icon-check'
        returning_html += content_tag(:th,
                                      ((USE_EPIC) ?
                                      label_tag('decrement',t(:calendar_page)[:headers][:decrement], class: 'decrement_days') +
                                      label_tag('day',t(:calendar_page)[:headers][:day]) +
                                      label_tag('increment', t(:calendar_page)[:headers][:increment], class: 'increment_days') +
                                      tag(:br) +
                                      text_field_tag("window_before", visit_group.window_before, class: "visit_window visit_window_before position_#{n} input_small", size: 1, :'data-position' => n - 1, :'data-window-before' => visit_group.window_before, update: "#{window_before_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                      text_field_tag("day", visit_group.day, class: "visit_day position_#{n}", maxlength: 4, size: 4, :'data-position' => n - 1, :'data-day' => visit_group.day, update: "#{day_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                      text_field_tag("window_after", visit_group.window_after, class: "visit_window visit_window_after position_#{n} input_small", size: 1, :'data-position' => n - 1, :'data-window-after' => visit_group.window_after, update: "#{window_after_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                      tag(:br)
                                      : label_tag('')) +
                                      text_field_tag("arm_#{arm.id}_visit_name_#{n}", visit_name, class: "visit_name", size: 10, :'data-arm_id' => arm.id, :'data-visit_position' => n - 1, :'data-service_request_id' => service_request.id) +
                                      tag(:br) +
                                      link_to((content_tag(:span, '', class: "ui-button-icon-primary ui-icon #{icon}") + content_tag(:span, 'Check All', class: 'ui-button-text')),
                                              "/service_requests/#{service_request.id}/toggle_calendar_column/#{n}/#{arm.id}?#{action}=true&portal=#{portal}",
                                              remote: true, role: 'button', class: 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only', id: "check_all_column_#{n}", data: ( visit_group.any_visit_quantities_customized?(service_request) ? { confirm: "This will reset custom values for this column, do you wish to continue?"} : nil)),
                                      width: 60, class: 'visit_number')
      end
    end

    ((page * 5) - arm.visit_count).times do
      returning_html += content_tag(:th, "", width: 70, class: 'visit_number')
    end

    raw(returning_html)
  end

  def visits_select_options(arm, pages)
    num_pages = (arm.visit_count / 5.0).ceil
    arr = []
    selected = pages[arm.id].to_i == 0 ? 1 : pages[arm.id].to_i

    num_pages.times do |x|
      page = x + 1
      beginning_visit = (page * 5) - 4
      ending_visit = (page * 5) > arm.visit_count ? arm.visit_count : (page * 5)

      option = ["Visits #{beginning_visit} - #{ending_visit} of #{arm.visit_count}", page, style: "font-weight:bold;"]
      arr << option

      (beginning_visit..ending_visit).each do |visit_number|
        visit_group = arm.visit_groups[visit_number - 1]

        if visit_group.day.present?
          arr << ["--#{visit_group.name}/Day #{visit_group.day}".html_safe, parent_page: page]
        else
          arr << ["--#{visit_group.name}".html_safe, parent_page: page]
        end
      end
    end

    options_for_select(arr, selected)
  end

  def generate_visit_navigation(arm, service_request, pages, tab, portal=nil, ssr_id=nil)
    page = pages[arm.id].to_i == 0 ? 1 : pages[arm.id].to_i

    if @merged
      pathMethod = method(:merged_calendar_service_request_service_calendars_path)
    elsif @review
      pathMethod = method(:refresh_service_calendar_service_request_path)
    else
      pathMethod = method(:table_service_request_service_calendars_path)
    end

    returning_html = ""

    returning_html += link_to((content_tag(:span, '', class: 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-w') + content_tag(:span, '<-', class: 'ui-button-text')),
                        pathMethod.call(service_request, page: page - 1, pages: pages, arm_id: arm.id, tab: tab, portal: portal, sub_service_request_id: ssr_id),
                        remote: true, role: 'button', class: 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only left-arrow') unless page <= 1

    returning_html += content_tag(:button, (content_tag(:span, '', class: 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-w') + content_tag(:span, '<-', class: 'ui-button-text')),
                                  class: 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only ui-button-disabled ui-state-disabled left-arrow', disabled: true) if page <= 1

    returning_html += content_tag(:span, t("calendar_page.labels.jump_to_visit"))

    returning_html += select_tag("jump_to_visit_#{arm.id}", visits_select_options(arm, pages), class: 'jump_to_visit', url: pathMethod.call(service_request, pages: pages, arm_id: arm.id, tab: tab, portal: portal, sub_service_request_id: ssr_id))

    unless (portal or @merged or @review)
      returning_html += link_to 'Move Visit', 'javascript:void(0)', class: 'ui-button ui-widget ui-state-default ui-corner-all move_visits', data: { arm_id: arm.id, tab: tab, sr_id: service_request.id, portal: portal }
    end

    returning_html += link_to((content_tag(:span, '', class: 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-e') + content_tag(:span, '->', class: 'ui-button-text')),
                              pathMethod.call(service_request, page: page + 1, pages: pages, arm_id: arm.id, tab: tab, portal: portal, sub_service_request_id: ssr_id),
                              remote: true, role: 'button', class: 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only right-arrow') unless ((page + 1) * 5) - 4 > arm.visit_count

    returning_html += content_tag(:button, (content_tag(:span, '', class: 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-e') + content_tag(:span, '->', class: 'ui-button-text')),
                                  class: 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only ui-button-disabled ui-state-disabled right-arrow', disabled: true) if ((page + 1) * 5) - 4 > arm.visit_count

    raw(returning_html)
  end

  def navigation_link(img_or_txt, location, class_name=nil)
    link_to img_or_txt, "javascript:void(0)", class: "navigation_link #{class_name}", location: location
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

  def display_service_in_catalog service, service_request, from_portal
    has_current_pricing_map = service.current_pricing_map rescue false # work around for current_pricing_map method raising false
    if (service.is_available? or service.is_available.nil?) and has_current_pricing_map
      render 'service', service: service, service_request: service_request, from_portal: from_portal
    end
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

  #Determines if an arm can be deleted in sparc proper, based on whether the request is in CWF and has patient data
  def can_be_deleted? arm
    arm.subjects.empty? ? true : arm.subjects.none?{|x| x.has_appointments?}
  end

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  #Will find a particular one time fee line item by its id, then determine if it has any associated fulfillments
  def one_time_fee_fulfillments? line_item_id
    has_fulfillments = false
    otf = LineItem.find(line_item_id)
    if !otf.fulfillments.empty?
      has_fulfillments = true
    end

    has_fulfillments
  end

  # If any of the subjects under the given arm have completed appointments, returns true
  def arm_has_subject_data? arm
    arm.subjects ? arm.subjects.any?{|subject| subject.calendar.appointments.any?{|appt| !appt.completed_at.nil?}} : false
  end

  def entity_visibility_class entity
    entity.is_available == false ? 'entity_visibility' : ''
  end

  def first_service?(service_request)
    service_request.line_items.count == 0
  end

  def display_protocol_id(service_request)
    if service_request.protocol
      return service_request.protocol.id
    else
      return ""
    end
  end

  def display_locked_organization(organization_name)
    content_tag(:a, organization_name+" **LOCKED**", href: 'javascript:void(0)')
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

  def navbar_link identifier, details, highlighted_link
    name, path = details
    highlighted = identifier == highlighted_link

    conditions = false

    if current_user
      conditions = case identifier
      when 'sparc_fulfillment'
        current_user.clinical_providers.empty? && !current_user.is_super_user?
      when 'sparc_catalog'
        current_user.catalog_managers.empty?
      when 'sparc_report'
        !current_user.is_super_user?
      else
        false
      end
    end

    render_navbar_link(name, path, highlighted) unless conditions
  end

  def render_navbar_link name, path, highlighted
    content_tag :li, link_to(name.to_s, path, target: '_blank', class: highlighted ? 'highlighted' : ''), class: 'dashboard nav-bar-link'
  end
end

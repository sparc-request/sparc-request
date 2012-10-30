module ApplicationHelper
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

  def line_item_visit_input line_item, visit, tab, totals_hash={}
    base_url = "/service_requests/#{line_item.service_request_id}/service_calendars?visit=#{visit.id}"
    case tab
    when 'template'
      check_box_tag "visits_#{visit.id}", 1, (visit.research_billing_qty.to_i > 0), :class => "line_item_visit_template visits_#{visit.id}", :update => "#{base_url}&tab=template"
    when 'quantity'
      content_tag(:div, visit.quantity, {:style => 'text-align:center', :class => "line_item_visit_quantity"}) 
    when 'billing_strategy'
      returning_html = ""
      returning_html += text_field_tag "visits_#{visit.id}_research_billing_qty", visit.research_billing_qty, :class => "line_item_visit_billing visits_#{visit.id}", :update => "#{base_url}&tab=billing_strategy&column=research_billing_qty"
      returning_html += text_field_tag "visits_#{visit.id}_insurance_billing_qty", visit.insurance_billing_qty, :class => "line_item_visit_billing visits_#{visit.id}", :update => "#{base_url}&tab=billing_strategy&column=insurance_billing_qty"
      returning_html += text_field_tag "visits_#{visit.id}_effort_billing_qty", visit.effort_billing_qty, :class => "line_item_visit_billing visits_#{visit.id}", :update => "#{base_url}&tab=billing_strategy&column=effort_billing_qty"
      raw(returning_html)
    when 'pricing'
      label_tag nil, currency_converter(totals_hash["#{visit.id}"]), :class => "line_item_visit_pricing"
    end
  end

  def generate_visit_header_row service_request, page
    page = page == 0 ? 1 : page
    beginning_visit = (page * 5) - 4
    ending_visit = (page * 5) > service_request.visit_count ? service_request.visit_count : (page * 5)
    returning_html = ""

    (beginning_visit .. ending_visit).each do |n|
      returning_html += content_tag(:th, "Visit #{n}", :width => 60, :class => 'visit_number')
    end

    ((page * 5) - service_request.visit_count).times do
      returning_html += content_tag(:th, "", :width => 60, :class => 'visit_number')
    end

    raw(returning_html)
  end

  def generate_visit_navigation service_request, page, tab
    page = page == 0 ? 1 : page
    beginning_visit = (page * 5) - 4
    ending_visit = (page * 5) > service_request.visit_count ? service_request.visit_count : (page * 5)
    returning_html = ""
    
    returning_html += link_to((content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-w') + content_tag(:span, '<-', :class => 'ui-button-text')), 
                              table_service_request_service_calendars_path(service_request, :page => page - 1, :tab => tab), 
                              :remote => true, :role => 'button', :class => 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only') unless page <= 1
    returning_html += content_tag(:button, (content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-w') + content_tag(:span, '<-', :class => 'ui-button-text')), 
                                  :class => 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only ui-button-disabled ui-state-disabled', :disabled => true) if page <= 1

    returning_html += content_tag(:span, "Visits #{beginning_visit} - #{ending_visit} of #{service_request.visit_count}", :class => 'visit_count')

    returning_html += link_to((content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-e') + content_tag(:span, '->', :class => 'ui-button-text')), 
                              table_service_request_service_calendars_path(service_request, :page => page + 1, :tab => tab), 
                              :remote => true, :role => 'button', :class => 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only') unless ((page + 1) * 5) - 4 > service_request.visit_count
    returning_html += content_tag(:button, (content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-e') + content_tag(:span, '->', :class => 'ui-button-text')), 
                                  :class => 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only ui-button-disabled ui-state-disabled', :disabled => true) if ((page + 1) * 5) - 4 > service_request.visit_count
    raw(returning_html)
  end

  def generate_review_visit_navigation service_request, page, tab
    page = page == 0 ? 1 : page
    beginning_visit = (page * 5) - 4
    ending_visit = (page * 5) > service_request.visit_count ? service_request.visit_count : (page * 5)
    returning_html = ""
    
    returning_html += link_to((content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-w') + content_tag(:span, '<-', :class => 'ui-button-text')), 
                              refresh_service_calendar_service_request_path(service_request, :page => page - 1, :tab => tab), 
                              :remote => true, :role => 'button', :class => 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only') unless page <= 1
    returning_html += content_tag(:button, (content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-w') + content_tag(:span, '<-', :class => 'ui-button-text')), 
                                  :class => 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only ui-button-disabled ui-state-disabled', :disabled => true) if page <= 1

    returning_html += content_tag(:span, "Visits #{beginning_visit} - #{ending_visit} of #{service_request.visit_count}", :class => 'visit_count')

    returning_html += link_to((content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-e') + content_tag(:span, '->', :class => 'ui-button-text')), 
                              refresh_service_calendar_service_request_path(service_request, :page => page + 1, :tab => tab), 
                              :remote => true, :role => 'button', :class => 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only') unless ((page + 1) * 5) - 4 > service_request.visit_count
    returning_html += content_tag(:button, (content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-e') + content_tag(:span, '->', :class => 'ui-button-text')), 
                                  :class => 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only ui-button-disabled ui-state-disabled', :disabled => true) if ((page + 1) * 5) - 4 > service_request.visit_count
    raw(returning_html)
  end
  
  def portal_link
    case Rails.env
    when "development"
      "localhost:3001"
    when "staging"
      "sparc-stg.musc.edu/portal"
    when "production"
      "sparc.musc.edu/portal"
    end
  end

  def navigation_link(img_or_txt, location, class_name=nil)
    link_to img_or_txt, "javascript:void(0)", :class => "navigation_link #{class_name}", :location => location
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
end

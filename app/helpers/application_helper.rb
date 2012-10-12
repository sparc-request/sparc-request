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

  def line_item_visit_input line_item, visit, tab
    case tab
    when 'template'
      check_box_tag "service_requests[line_item_items][#{line_item.id}][visits][#{visit.id}]"
    when 'quantity'
      check_box_tag "service_requests[line_item_items][#{line_item.id}][visits][#{visit.id}]"
    when 'billing_strategy'
      check_box_tag "service_requests[line_item_items][#{line_item.id}][visits][#{visit.id}]"
    when 'pricing'
      "$0.00"
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
      returning_html += content_tag(:th, "&nbsp;", :width => 60, :class => 'visit_number')
    end

    raw(returning_html)
  end

  def generate_visit_navigation service_request, page, tab
    page = page == 0 ? 1 : page
    beginning_visit = (page * 5) - 4
    ending_visit = (page * 5) > service_request.visit_count ? service_request.visit_count : (page * 5)
    returning_html = ""
    
    returning_html += link_to((content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-w') + content_tag(:span, '<-', :class => 'ui-button-text')), eval("#{tab}_service_request_service_calendars_path(service_request, :page => page - 1)"), 
                              :remote => true, :role => 'button', :class => 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only') unless page <= 1
    returning_html += content_tag(:button, (content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-w') + content_tag(:span, '<-', :class => 'ui-button-text')), 
                                  :class => 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only ui-button-disabled ui-state-disabled', :disabled => true) if page <= 1

    returning_html += content_tag(:span, "Visits #{beginning_visit} - #{ending_visit} of #{service_request.visit_count}", :class => 'visit_count')

    returning_html += link_to((content_tag(:span, '', :class => 'ui-button-icon-primary ui-icon ui-icon-circle-arrow-e') + content_tag(:span, '->', :class => 'ui-button-text')), eval("#{tab}_service_request_service_calendars_path(service_request, :page => page + 1)"), 
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

  def navigation_link(img_or_txt, location)
    link_to img_or_txt, "javascript:void(0)", :class => 'navigation_link', :location => location
  end
end

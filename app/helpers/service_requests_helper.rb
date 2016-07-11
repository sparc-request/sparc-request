module ServiceRequestsHelper

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

  def institution_accordion(institutions, locked_ids, organization=nil)
    returning_html    = ""
    process_ssr_found = nil

    institutions.each do |institution|
      next unless (organization.nil? || (process_ssr_found = ssr_org == institution) || organization.parents.include?(institution))
      locked = locked_ids.include?(institution.id)

      returning_html += content_tag(:h3, organization_name_display(institution, locked), class: ['btn institution-header', institution.css_class, locked ? 'locked' : ''], data: { id: institution.id })
      returning_html += content_tag(:div,
                          content_tag(:div, provider_accordion(institution.providers, locked_ids, organization, process_ssr_found), class: 'provider-accordion'),
                          class: 'institution'
                        )

    end

    returning_html.html_safe
  end

  def core_accordion(organization, ssr_org, service_request, locked_ids, process_ssr_found, from_portal)
    returning_html = ""

    if ssr_org.present? && !process_ssr_found
      returning_html += core_html(ssr_org, organization, service_request, false, from_portal)
    else
      organization.cores.where(is_available: [true, nil]).order('`order`').each do |core|
        returning_html += core_html(core, organization, service_request, locked_ids.include?(core.id), from_portal)
      end
    end

    returning_html.html_safe
  end

  def organization_name_display(organization, locked)
    locked ? organization.name+" **LOCKED**" : organization.name
  end

  def organization_description_display(organization)
    organization.description.present? ? organization.description : t(:proper)[:catalog][:accordion][:no_description]
  end

  def display_service_in_catalog(service, service_request, from_portal)
    if [true, nil].include?(service.is_available) && service.current_pricing_map
      render 'service', service: service, service_request: service_request, from_portal: from_portal
    else
      ""
    end
  end

  # RIGHT NAVIGATION BUTTONS
  def faq_helper
    if USE_FAQ_LINK
      link_to t(:proper)[:right_navigation][:faqs][:header], FAQ_URL, target: :blank, class: 'btn btn-primary btn-lg btn-block'
    else
      content_tag(:button, t(:proper)[:right_navigation][:faqs][:header], class: 'faq-button btn btn-primary btn-lg btn-block', href: 'javascript:void(0)')
    end
  end

  def feedback_helper
    if USE_FEEDBACK_LINK
      link_to t(:proper)[:right_navigation][:feedback][:header], t(:proper)[:right_navigation][:redcap_survey], target: :blank, class: 'btn btn-primary btn-lg btn-block'
    else
      content_tag(:button, t(:proper)[:right_navigation][:feedback][:header], class: 'feedback-button btn btn-primary btn-lg btn-block', href: 'javascript:void(0)')
    end
  end

  private

  def provider_accordion(providers, locked_ids, organization, process_ssr_found)
    returning_html = ""

    providers.each do |provider|
      next unless (organization.nil? || process_ssr_found || (process_ssr_found = ssr_org == provider) || organization.parents.include?(provider))
      locked = locked_ids.include?(provider.id)

      returning_html += content_tag(:h3, organization_name_display(provider, locked), class: ['btn', provider.css_class, 'provider-header', locked ? 'locked' : ''], data: { id: provider.id })
      returning_html += content_tag(:div, program_accordion(provider.programs, locked_ids, organization, process_ssr_found), class: 'provider')
    end

    returning_html.html_safe
  end

  def program_accordion(programs, locked_ids, organization, process_ssr_found)
    returning_html = ""

    programs.each do |program|
      next unless (organization.nil? || process_ssr_found || (process_ssr_found = ssr_org == program) || organization.parents.include?(program))
      locked = locked_ids.include?(program.id)

      returning_html += content_tag(:h4, organization_name_display(program, locked), class: ['btn btn-default btn-sm program-link', locked ? 'locked' : ''], data: { id: program.id, process_ssr_found: process_ssr_found })
    end

    returning_html.html_safe
  end

  def core_html(core, parent, service_request, locked, from_portal)
    services = ""
    
    core.services.order('`order`, `name`').each do |service|
      services += display_service_in_catalog(service, service_request, from_portal)
    end

    [ content_tag(:h3, organization_name_display(core, locked), class: ['btn core-header', css_class(parent), locked ? 'locked' : '']),
      content_tag(:div,
        content_tag(:div, organization_description_display(core), class: 'description core-description col-sm-12')+services.html_safe,
        class: 'core-view'
      )].join('').html_safe
  end
end
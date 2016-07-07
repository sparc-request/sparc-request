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

      returning_html += content_tag(:h3, organization_display(institution, locked), class: [institution.css_class, locked ? 'locked' : ''])
      returning_html += content_tag(:div,
                          content_tag(:div, provider_accordion(institution.providers, locked_ids, organization, process_ssr_found), class: 'provider-accordion'),
                          class: 'institution'
                        )

    end

    returning_html.html_safe
  end

  def provider_accordion(providers, locked_ids, organization, process_ssr_found)
    returning_html = ""

    providers.each do |provider|
      next unless (organization.nil? || process_ssr_found || (process_ssr_found = ssr_org == provider) || organization.parents.include?(provider))
      locked = locked_ids.include?(provider.id)

      returning_html += content_tag(:h3, organization_display(provider, locked), class: [provider.css_class, 'provider-header', locked ? 'locked' : ''])
      returning_html += content_tag(:div, program_accordion(provider.programs, locked_ids, organization, process_ssr_found), class: 'provider')
    end

    returning_html.html_safe
  end

  def program_accordion(programs, locked_ids, organization, process_ssr_found)
    returning_html = ""

    programs.each do |program|
      next unless (organization.nil? || process_ssr_found || (process_ssr_found = ssr_org == program) || organization.parents.include?(program))
      locked = locked_ids.include?(program.id)

      returning_html += content_tag(:h4, organization_display(program, locked), class: [program.css_class, locked ? 'locked' : ''])
    end

    returning_html.html_safe
  end

  def organization_display(organization, locked)
    if locked
      content_tag(:a, organization_name+" **LOCKED**", href: 'javascript:void(0)')
    else
      link_to organization.name, update_description_catalog_path(organization)
    end
  end
end
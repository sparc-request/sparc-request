module Portal::ProjectsHelper
  def user_rights(project_role)
    if project_role.can_switch_to?('approve', project_role.project_rights) #user.auth_change_study
      return  true
    elsif project_role.can_switch_to?('request', project_role.project_rights) #user.req_app_services
      return true
    elsif project_role.can_switch_to?('view', project_role.project_rights) #user.view_only_rights
      return false
    else
      return false
    end
  end

  def check_or_x(boolean)
    boolean ? content_tag(:span, '', :class => 'icon check') : content_tag(:span, '', :class => 'icon uncheck')
  end

  def pretty_program_core(ssr)
    org = ssr.organization
    core = org if org.is_a?(Core)
    program = core ? core.parent : org
    if core
      if !core.abbreviation.blank?
        "#{program.abbreviation}/#{core.abbreviation}"
      else
        "#{program.name}/#{core.name}"
      end
    else
      program.name
    end
  end

  def display_funding_source(project)
    if project.funding_status == 'funded'
      _funding_sources = FUNDING_SOURCES.map {|k,v| {v => k}}
      _funding_sources.select do |obj|
        return "Funding Source: #{obj[project.funding_source]}" if obj.has_key?(project.funding_source)
      end
    elsif project.funding_status == 'pending_funding'
      _potential_funding_sources = POTENTIAL_FUNDING_SOURCES.map {|k,v| {v => k}}
      _potential_funding_sources.select do |obj|
        return "Potential Funding Source: #{obj[project.potential_funding_source]}" if obj.has_key?(project.potential_funding_source)
      end
    else
      ''
    end
  end

  def display_funding_source_title(project)
    if project.funding_status == 'funded'
      'Funding Source: '
    elsif project.funding_status == 'pending_funding'
      'Potential Funding Source:'
    else
      ''
    end
  end

  def display_funding_source_or_potential(project)
    if project.funding_status == 'funded'
      project.try(:funding_source).try(:titleize)
    elsif project.funding_status == 'pending_funding'
      project.try(:potential_funding_source).try(:titleize)
    else
      ''
    end
  end

  def display_funding_status(status)
    case status
    when 'pending_funding' then 'Pending Funding'
    when 'funded'          then 'Funded'
    end
  end

  def display_viewer_funding_source(project)
    case project.potential_funding_source || project.funding_source
    when 'college'      then 'College Department'
    when 'federal'      then 'Federal'
    when 'foundation'   then 'Foundation/Organization'
    when 'industry'     then 'Industry-Initiated/Industry-Sponsored'
    when 'investigator' then 'Investigator-Initiated/Industry-Sponsored'
    when 'internal'     then 'Internal Funded Pilot Project'
    when 'unfunded'     then 'Unfunded'
    end
  end

end

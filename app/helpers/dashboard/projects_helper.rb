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

module Dashboard::ProjectsHelper
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
      (FUNDING_SOURCES.invert)[project.funding_source]
    elsif project.funding_status == 'pending_funding'
      (POTENTIAL_FUNDING_SOURCES.invert)[project.potential_funding_source]
    else
      ''
    end
  end

  def display_funding_source_title(project)
    if project.funding_status == 'funded'
      'Funding Source:'
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

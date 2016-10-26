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

require 'csv'

class CtrcServicesReport < Report
  def default_output_file
    return './ctrc_services_report.csv'
  end

  def run
    CSV.open(output_file, 'wb') do |csv|
      # Column Headers
      csv << ['Core',
              'Service',
              'True Rate',
              'College Department',
              'Federal',
              'Foundation/Organization',
              'Industry-Initiated/Industry-Sponsored',
              'Investigator-Initiated/Industry-Sponsored',
              'Internal Funded Pilot Project']

      # Get all CTRC organizations
      ctrcs = Organization.all.select {|x| x.tags.map(&:name).include?('ctrc')}
      ctrcs.each do |ctrc|
        if ctrc.cores
          ctrc.cores.each do |core|
            core.services.each do |service|
              row = []
              row << service.organization.name
              row << service.name
              row << service.displayed_pricing_map.full_rate.to_f / 100.0
              row << find_applicable_rate(service, 'college') / 100.0
              row << find_applicable_rate(service, 'federal') / 100.0
              row << find_applicable_rate(service, 'foundation') / 100.0
              row << find_applicable_rate(service, 'industry') / 100.0
              row << find_applicable_rate(service, 'investigator') / 100.0
              row << find_applicable_rate(service, 'internal') / 100.0

              csv << row
            end
          end
        end
      end
    end
  end

  def find_applicable_rate service, funding_source
    pricing_map = service.displayed_pricing_map
    pricing_setup = service.organization.current_pricing_setup
    selected_rate_type = pricing_setup.rate_type(funding_source)
    applied_percentage = pricing_setup.applied_percentage(selected_rate_type)
    rate = pricing_map.applicable_rate(selected_rate_type, applied_percentage)
    return rate
  end
end


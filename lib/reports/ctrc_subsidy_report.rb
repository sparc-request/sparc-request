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

def helper
  ActionController::Base.helpers
end

class CtrcSubsidyReport < Report
  def self.currency_converter cents
    helper.number_to_currency(Service.cents_to_dollars(cents))
  end

  def default_output_file
    return "#{Time.now.strftime('%F')}_ctrc_subsidy_report.csv"
  end

  def two_decimal_places float
    unless float.nan?
      sprintf("%.2f", float * 100.0)
    end
  end

  def output_file
    return './ctrc_subsidies_report.csv'
  end

  def run
    CSV.open(output_file, 'wb') do |csv|
      # Column Headers
      csv << ['SRID',
              'PI',
              'Total Cost',
              'PI Contribution',
              'Subsidy',
              '(Potential)Funding Source']

      # Get all sub service requests belonging to the CTRC
      SubServiceRequest.all.select {|x| x.ctrc?}.each do |ssr|
        #unless ["draft", "first_draft"].include? ssr.status
        if ["in_process", "ctrc_review", "ctrc_approved"].include? ssr.status # per request by Lane we only want this report to include these statuses
          if ssr.service_request
            if ssr.service_request.protocol
              row = []
              puts '#'*100
              puts "#{ssr.service_request.protocol.id}-#{ssr.ssr_id}"
              row << "#{ssr.service_request.protocol.id}-#{ssr.ssr_id}"
              row << "#{ssr.service_request.protocol.primary_principal_investigator.full_name}"
              row << CtrcSubsidyReport.currency_converter(ssr.direct_cost_total)
              puts CtrcSubsidyReport.currency_converter(ssr.direct_cost_total)
              if ssr.subsidy
                row << CtrcSubsidyReport.currency_converter(ssr.subsidy.pi_contribution)
                puts CtrcSubsidyReport.currency_converter(ssr.subsidy.pi_contribution)
                row << two_decimal_places(ssr.try(:subsidy).try(:percent_subsidy)) rescue nil
                puts ssr.subsidy.percent_subsidy
              else
                row << ""
                row << ""
              end
              row << ssr.service_request.protocol.display_funding_source_value

              csv << row
            end
          end
        end
      end

    end
  end

end

if __FILE__ == $0 then
  CtrcSubsidyReport.run
end


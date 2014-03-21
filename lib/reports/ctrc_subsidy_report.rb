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


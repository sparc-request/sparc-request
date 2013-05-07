require 'csv'

def helper
  ActionController::Base.helpers
end

def two_decimal_places float
  unless float.nan?
    sprintf("%.2f", float * 100.0)
  end
end

class CtrcSubsidyReport

  def self.currency_converter cents
    helper.number_to_currency(Service.cents_to_dollars(cents))
  end

  def self.generate_report
    CSV.open('./ctrc_subsidies_report.csv', 'wb') do |csv|
      # Column Headers
      csv << ['SRID',
              'Total Cost',
              'PI Contribution',
              'Subsidy']

      # Get all sub service requests belonging to the CTRC
      SubServiceRequest.all.select {|x| x.ctrc?}.each do |ssr|
        unless ["draft", "first_draft"].include? ssr.status
          if ssr.service_request
            if ssr.service_request.protocol
              row = []
              puts '#'*100
              puts "#{ssr.service_request.protocol.id}-#{ssr.ssr_id}"
              row << "#{ssr.service_request.protocol.id}-#{ssr.ssr_id}"
              row << CtrcSubsidyReport.currency_converter(ssr.direct_cost_total)
              puts CtrcSubsidyReport.currency_converter(ssr.direct_cost_total)
              if ssr.subsidy
                row << CtrcSubsidyReport.currency_converter(ssr.subsidy.pi_contribution)
                puts CtrcSubsidyReport.currency_converter(ssr.subsidy.pi_contribution)
                row << two_decimal_places(ssr.subsidy.percent_subsidy)
                puts ssr.subsidy.percent_subsidy
              else
                row << ""
                row << ""
              end

              csv << row
            end
          end
        end
      end

    end
  end

end

CtrcSubsidyReport.generate_report